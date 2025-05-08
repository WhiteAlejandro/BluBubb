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
  late NearbyService nearbyService; // Service that manages Bluetooth connections
  List<Device> _devicesList = []; // List of discovered devices from nearby service
  Set<String> _outgoingRequests = {}; // Tracks device IDs we initiated connection with

  @override
  void initState() {
    super.initState();
    _initializeNearbyService(); // Start the nearby service when screen initializes
  }

  /// Initializes the NearbyService and begins scanning for nearby devices
  /// Also starts advertising the current device's presence
  void _initializeNearbyService() async {
    nearbyService = NearbyService();

    // Initialize the NearbyService with service type, device name, and strategy
    await nearbyService.init(
      serviceType: 'blububb', // The unique service type for this app
      deviceName: widget.deviceName, // Use the passed-in device name (username)
      strategy: Strategy.P2P_CLUSTER, // Peer-to-peer clustering strategy for discovery
      callback: (isRunning) {
        if (isRunning) {
          // Service started successfully, begin searching for peers
          print("Service is running.");
          nearbyService.startBrowsingForPeers(); // Start looking for nearby peers
          nearbyService.startAdvertisingPeer();  // Advertise this device's presence
        } else {
          // Failed to start the nearby service
          print("Service failed to start.");
        }
      },
    );

    // Subscribe to changes in discovered devices (devices found while browsing)
    nearbyService.stateChangedSubscription(callback: (devicesList) {
      setState(() {
        _devicesList = devicesList; // Update the list of devices when new ones are found
      });

      // Show a connection prompt if a device just connected
      for (final device in devicesList) {
        if (device.state == SessionState.connected) {
          if (device.state == SessionState.connected &&
              !_outgoingRequests.contains(device.deviceId)) {
            _showConnectionPrompt(device); // Only show prompt if we did NOT invite them
          } else{
            // Automatically navigate sender to chat screen
            Navigator.pushNamed(context, '/chat', arguments: device);
          }
        }
      }
    });
  }

  /// Sends a connection request to the selected device
  void _connectToDevice(Device device) async {
    try {
      // Attempt to send an invite to the selected device for peer connection
      _outgoingRequests.add(device.deviceId); // Mark this device as invited
      await nearbyService.invitePeer(
        deviceID: device.deviceId, // Device ID of the target device
        deviceName: device.deviceName, // Name of the target device
      );
      // Show a toast notification to inform the user that the request has been sent
      Fluttertoast.showToast(
        msg: 'Connection request sent to ${device.deviceName}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      // Show a toast notification if the connection request fails
      Fluttertoast.showToast(
        msg: 'Failed to connect to ${device.deviceName}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// Shows a prompt dialog asking the user whether to accept or decline a connection
  void _showConnectionPrompt(Device device) {
    // Display an alert dialog to ask the user to accept or decline the incoming chat request
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing dialog without action
      builder: (context) {
        return AlertDialog(
          title: Text("Chat Request"),
          content: Text("Accept chat request from ${device.deviceName}?"),
          actions: [
            // Decline the request and disconnect the peer
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                nearbyService.disconnectPeer(deviceID: device.deviceId); // Disconnect
              },
              child: const Text("Decline"),
            ),
            // Accept the request and navigate to the chat screen
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(context, '/chat', arguments: device); // Go to chat screen
              },
              child: const Text("Accept"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Stop browsing and advertising when leaving the screen to clean up resources
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Device")),
      body: Column(
        children: [
          // Display the device's name that is currently discoverable
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Discoverable as: ${widget.deviceName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          // Display the list of nearby devices, or show a loading message if none found
          Expanded(
            child: _devicesList.isEmpty
                ? const Center(child: Text("Searching for nearby devices..."))
                : ListView.builder(
                    itemCount: _devicesList.length, // Number of devices found
                    itemBuilder: (context, index) {
                      final device = _devicesList[index];
                      return Card(
                        child: ListTile(
                          title: Text(device.deviceName), // Display device name
                          onTap: () => _connectToDevice(device), // Initiate connection on tap
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