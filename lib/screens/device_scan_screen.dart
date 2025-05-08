import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

/// Screen to scan for and connect to nearby devices using Bluetooth.
class DeviceScanScreen extends StatefulWidget {
  @override
  _DeviceScanScreenState createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  late NearbyService nearbyService; // Service for managing peer-to-peer connections
  List<Device> _devicesList = [];   // Dynamic list of discovered/connected devices

  @override
  void initState() {
    super.initState();
    _initializeNearbyService(); // Begin Bluetooth discovery when screen loads
  }

  /// Initializes NearbyService and sets up device discovery.
  Future<void> _initializeNearbyService() async {
    nearbyService = NearbyService();

    // Start the NearbyService with appropriate service type and strategy
    await nearbyService.init(
      serviceType: 'blububb', // MUST be consistent across all devices
      deviceName: 'BluBubb Device',
      strategy: Strategy.P2P_CLUSTER, // P2P_CLUSTER supports multiple peers
      callback: (bool isRunning) {
        if (isRunning) {
          print("Nearby service running. Starting peer discovery...");
          nearbyService.startBrowsingForPeers();     // Begin scanning
          nearbyService.startAdvertisingPeer();      // Make this device discoverable
        } else {
          print("Nearby service failed to start.");
        }
      },
    );

    // Subscribe to state changes (e.g., devices found, updated, or removed)
    nearbyService.stateChangedSubscription(callback: (List<Device> devicesList) {
      setState(() {
        _devicesList = devicesList; // Update UI with new device list
      });
    });
  }

  /// Connects to a selected device by sending an invitation.
  void _connectToDevice(Device device) async {
    try {
      await nearbyService.invitePeer(
        deviceID: device.deviceId,
        deviceName: device.deviceName,
      );

      Fluttertoast.showToast(
        msg: 'Connection request sent to ${device.deviceName}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print('Connection error: $e');

      Fluttertoast.showToast(
        msg: 'Failed to connect to ${device.deviceName}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// Clean up resources when this screen is closed.
  @override
  void dispose() {
    nearbyService.stopBrowsingForPeers();     // Stop scanning
    nearbyService.stopAdvertisingPeer();      // Stop advertising
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Device")),
      body: _devicesList.isEmpty
          ? const Center(child: Text("Searching for nearby devices..."))
          : ListView.builder(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                final device = _devicesList[index];

                return Card(
                  child: ListTile(
                    title: Text(device.deviceName),
                    subtitle: Text(device.deviceId),
                    onTap: () => _connectToDevice(device), // Attempt to connect when tapped
                  ),
                );
              },
            ),
    );
  }
}