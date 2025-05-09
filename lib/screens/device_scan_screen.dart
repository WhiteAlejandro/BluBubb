import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'chat_screen.dart';

/// This screen displays nearby devices using Bluetooth and enables peer-to-peer connections.
/// It advertises this device's presence and listens for nearby peers.
/// Once a connection is established, it automatically navigates to the chat screen.
class DeviceScanScreen extends StatefulWidget {
  /// The name of this device/user, passed from the home screen
  final String deviceName;

  const DeviceScanScreen({super.key, required this.deviceName});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  late NearbyService nearbyService;         // Manages peer discovery and connections
  List<Device> _devicesList = [];           // List of devices discovered nearby

  @override
  void initState() {
    super.initState();
    _initializeNearbyService();             // Start Bluetooth service on init
  }

  /// Initializes NearbyService, sets up advertising and discovery,
  /// and registers a callback to respond to device state changes.
  void _initializeNearbyService() async {
    nearbyService = NearbyService();

    await nearbyService.init(
      serviceType: 'blububb',
      deviceName: widget.deviceName,
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) {
        if (isRunning) {
          nearbyService.startBrowsingForPeers();
          nearbyService.startAdvertisingPeer();
        }
      },
    );

    nearbyService.stateChangedSubscription(callback: (devicesList) {
      setState(() {
        _devicesList = devicesList;
      });

      for (final device in devicesList) {
        if (device.state == SessionState.connected) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                device: device,
                nearbyService: nearbyService,
                deviceName: widget.deviceName,
              ),
            ),
          );
        }
      }
    });
  }

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
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Override Android system back button to go home
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select a Device"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ),
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
      ),
    );
  }
}