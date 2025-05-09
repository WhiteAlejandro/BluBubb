import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'device_scan_screen.dart'; // Import the screen for scanning and connecting to new devices

/// The ChatScreen handles real-time peer-to-peer messaging using Bluetooth.
/// It shows a conversation-style interface with message bubbles aligned left or right based on sender.
class ChatScreen extends StatefulWidget {
  final Device device; // The connected peer device
  final NearbyService nearbyService; // Service handling Bluetooth communication
  final String deviceName; // Local device name

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
  final List<_ChatMessage> _messages = []; // List of all messages in the current session
  final TextEditingController _textController = TextEditingController(); // Controller for the text input field

  StreamSubscription<dynamic>? _stateSubscription; // Subscription to device connection state updates
  StreamSubscription<dynamic>? _dataSubscription;  // Subscription to incoming message data

  @override
  void initState() {
    super.initState();

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
        // Add the received message to the UI, marked as received
        setState(() {
          _messages.add(_ChatMessage(
            content: data['message'] ?? '',
            isSentByMe: false,
          ));
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

    // Update the message list with the sent message
    setState(() {
      _messages.add(_ChatMessage(
        content: text,
        isSentByMe: true,
      ));
    });

    _textController.clear(); // Clear the input box after sending
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceScanScreen(deviceName: widget.deviceName),
      ),
      (route) => false, // Remove all previous routes from the stack
    );
  }

  @override
  void dispose() {
    // Cancel stream subscriptions and clean up controller
    _stateSubscription?.cancel();
    _dataSubscription?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Override Android back button to ensure disconnection occurs
      onWillPop: () async {
        await _disconnect(); // Properly disconnect before exiting
        return false; // Prevent default navigation behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat with ${widget.device.deviceName}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _disconnect, // Manual disconnect on back icon tap
          ),
        ),
        body: Column(
          children: [
            // Message list display
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    // Align to right if sent by this device, else to the left
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

            // Divider line between messages and input area
            const Divider(height: 1),

            // Message input and send button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Text input field
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
                  // Send button
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

/// Internal model class for a chat message
/// Each message has text content and a flag to indicate sender (me or peer)
class _ChatMessage {
  final String content;    // The text of the message
  final bool isSentByMe;   // True if this device sent the message

  _ChatMessage({
    required this.content,
    required this.isSentByMe,
  });
}