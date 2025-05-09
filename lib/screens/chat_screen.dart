import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'device_scan_screen.dart'; // Make sure the path is correct based on your project structure

class ChatScreen extends StatefulWidget {
  final Device device; // The connected device
  final NearbyService nearbyService; // The NearbyService instance managing the connection
  final String deviceName;

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
  StreamSubscription<dynamic>? _stateSubscription;

  @override
  void initState() {
    super.initState();

    // Subscribe to device state changes
    _stateSubscription = widget.nearbyService.stateChangedSubscription(
      callback: (devicesList) {
        for (final d in devicesList) {
          // If the device we're chatting with disconnects, navigate back to ScanScreen
          if (d.deviceId == widget.device.deviceId &&
              d.state != SessionState.connected) {
            if (mounted) {
              _navigateToScanScreen();
            }
          }
        }
      },
    );
  }

  /// Disconnect from the peer and go to ScanScreen
  Future<void> _disconnect() async {
    try {
      await widget.nearbyService.disconnectPeer(
        deviceID: widget.device.deviceId,
      );
      await widget.nearbyService.stopBrowsingForPeers();
      await widget.nearbyService.stopAdvertisingPeer();
    } catch (e) {
      debugPrint('Error while disconnecting: $e');
    }

    if (mounted) {
      _navigateToScanScreen();
    }
  }

  void _navigateToScanScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
      builder: (_) => DeviceScanScreen(deviceName: widget.deviceName), // Pass the device name to the scan screen
      ),
      (route) => false, // Clear all previous routes
    );
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disconnect(); // Manually disconnect
        return false;        // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat with ${widget.device.deviceName}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _disconnect, // Trigger disconnect when back icon is tapped
          ),
        ),
        body: const Center(
          child: Text(
            'Chat screen (messaging to be implemented)',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}