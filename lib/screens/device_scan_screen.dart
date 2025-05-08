import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class DeviceScanScreen extends StatefulWidget {
  final String deviceName; // Username passed from HomeScreen

  const DeviceScanScreen({super.key, required this.deviceName});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  late NearbyService nearbyService;        // Main service to manage Bluetooth connections
  List<Device> _devicesList = [];          // List of discovered devices

  @override
  void initState() {
    super.initState();
    _initializeNearbyService();            // Start the nearby service when screen is initialized
  }

  /// Initializes the NearbyService with the given device name (username),
  /// sets the strategy, and starts scanning for peers.
  void _initializeNearbyService() async {
  nearbyService = NearbyService();

  await nearbyService.init(
    serviceType: 'blububb',
    deviceName: widget.deviceName,
    strategy: Strategy.P2P_CLUSTER,
    callback: (isRunning) {
      if (isRunning) {
        print("Service is running, starting to browse and advertise...");
        nearbyService.startBrowsingForPeers();
        nearbyService.startAdvertisingPeer();
      } else {
        print("Nearby service failed to start.");
      }
    },
  );

  // Listen for device state changes (connected, disconnected, found, etc.)
  nearbyService.stateChangedSubscription(callback: (devicesList) {
    setState(() {
      _devicesList = devicesList;
    });

    // Check if any device has just connected
    for (var device in devicesList) {
      if (device.state == SessionState.connected) {
        print('Connected to ${device.deviceName}');
        Fluttertoast.showToast(
          msg: 'Connected to ${device.deviceName}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        // TODO: Navigate to chat screen
      } else if (device.state == SessionState.notConnected) {
        print('Disconnected from ${device.deviceName}');
      }
    }
  });

  // Optionally handle received data
  nearbyService.dataReceivedSubscription(callback: (data) {
    print('Data received from ${data["deviceId"]}: ${data["message"]}');
    // TODO: Display incoming messages
  });
}

  /// Attempt to connect to the tapped device
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
      Fluttertoast.showToast(
        msg: 'Failed to connect to ${device.deviceName}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    nearbyService.stopBrowsingForPeers();   // Clean up when screen is closed
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Device")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Discoverable as: ${widget.deviceName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: _devicesList.isEmpty
                ? const Center(child: Text("Searching for nearby devices..."))
                : ListView.builder(
                    itemCount: _devicesList.length,
                    itemBuilder: (context, index) {
                      final device = _devicesList[index];
                      return Card(
                        child: ListTile(
                          title: Text(device.deviceName),
                          onTap: () => _connectToDevice(device),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}