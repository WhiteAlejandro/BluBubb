import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:blububb/messages/chat_message.dart'; // Import the correct chat message model
import '/messages/chat_storage.dart'; // Import the chat storage for saving/loading messages

typedef AsyncCallback = Future<void> Function();

/// The ChatScreen handles real-time peer-to-peer messaging using Bluetooth.
/// It shows a conversation-style interface with message bubbles aligned left or right based on sender.
class ChatScreen extends StatefulWidget {
  final Device device; // The connected peer device
  final NearbyService nearbyService; // Service handling Bluetooth communication
  final String deviceName; // Local device name used for chat storage

  const ChatScreen({
    super.key,
    required this.device,
    required this.nearbyService,
    required this.deviceName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = []; // List of all messages in the current session
  final TextEditingController _textController = TextEditingController(); // Controller for the text input field

  StreamSubscription<dynamic>? _stateSubscription; // Subscription to device connection state updates
  StreamSubscription<dynamic>? _dataSubscription;  // Subscription to incoming message data
  final ScrollController _scrollController = ScrollController(); // Controls automatic scrolling of the chat list
  late final LifecycleEventHandler _lifecycleHandler;

  @override
  void initState() {
    super.initState();

    // Register lifecycle observer
    _lifecycleHandler = LifecycleEventHandler(
      onMetricsChanged: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      },
    );

    WidgetsBinding.instance.addObserver(_lifecycleHandler);

    // Load saved messages for the current username
    final storedMessages = ChatStorage.getMessages(widget.deviceName);
    for (var msg in storedMessages) {
      _messages.add(ChatMessage(content: msg.content, isSentByMe: msg.isSentByMe, timestamp: msg.timestamp));
    }
    // Scroll to bottom after messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    // Listen for connection state changes (e.g., disconnection)
    _stateSubscription = widget.nearbyService.stateChangedSubscription(
      callback: (devicesList) {
        for (final d in devicesList) {
          // If the connected device is no longer connected, return to scan screen
          if (d.deviceId == widget.device.deviceId &&
              d.state != SessionState.connected) {
            if (mounted) _navigateToScanScreen();
          }
        }
      },
    );

    // Listen for incoming data (messages)
    _dataSubscription = widget.nearbyService.dataReceivedSubscription(
      callback: (data) {
        final receivedMsg = ChatMessage(
          content: data['message'] ?? '',
          isSentByMe: false,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(receivedMsg);
        });

        // Save updated messages
        _saveMessages();

        // Scroll to the latest message after receiving
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
    );
  }

  /// Sends a message to the connected peer and updates the local UI
  void _sendMessage() {
    final text = _textController.text.trim();

    if (text.isEmpty) return; // Ignore empty messages

    // Send the message to the connected peer
    widget.nearbyService.sendMessage(
      widget.device.deviceId,
      text,
    );

    final sentMsg = ChatMessage(
      content: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
    );

    // Update the message list with the sent message
    setState(() {
      _messages.add(sentMsg);
    });

    _textController.clear(); // Clear the input box after sending

    // Save updated messages
    _saveMessages();

    // Scroll to the latest message after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Save messages using ChatStorage under the current deviceName (username)
  void _saveMessages() {
    final messageObjects = _messages
        .map((m) => ChatMessage(content: m.content, isSentByMe: m.isSentByMe, timestamp: m.timestamp))
        .toList();
    ChatStorage.saveMessages(widget.deviceName, messageObjects);
  }

  /// Handles disconnection from peer and cleanup
  Future<void> _disconnect() async {
    try {
      await widget.nearbyService.disconnectPeer(deviceID: widget.device.deviceId);
      await widget.nearbyService.stopBrowsingForPeers();
      await widget.nearbyService.stopAdvertisingPeer();
    } catch (e) {
      debugPrint('Error while disconnecting: $e');
    }

    // Navigate back to the device scan screen
    if (mounted) _navigateToScanScreen();
  }

  /// Navigates to the device scan screen, clearing previous routes
  void _navigateToScanScreen() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/scan',
      (route) => false,
      arguments: widget.deviceName,
    );
  }

  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    // Cancel stream subscriptions and clean up controllers
    _stateSubscription?.cancel();
    _dataSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disconnect();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Let Flutter adjust for the keyboard
        appBar: AppBar(
          title: Text('Chat with ${widget.device.deviceName}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _disconnect,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isSentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: msg.isSentByMe
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        msg.content,
                        style: TextStyle(
                          color: msg.isSentByMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(
                8,
                4,
                8,
                MediaQuery.of(context).viewPadding.bottom + 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback onMetricsChanged;

  LifecycleEventHandler({required this.onMetricsChanged});

  @override
  void didChangeMetrics() {
    onMetricsChanged(); // Trigger when the keyboard appears or disappears
  }
}