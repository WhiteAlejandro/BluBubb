import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  _DeviceScanScreenState createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  List<BluetoothDevice> _devicesList = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  @override
  void dispose() {
    _isScanning = false;
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  // Check permissions and listen for adapter state before scanning
  Future<void> _checkPermissionsAndScan() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // Listen for state changes (to handle cases when Bluetooth is turned on after page load)
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on && !_isScanning) {
        _startScan();
      }
    });

    // Start scan immediately if Bluetooth is already on
    final currentState = await FlutterBluePlus.adapterState.first;
    if (currentState == BluetoothAdapterState.on) {
      _startScan();
    } else {
      Fluttertoast.showToast(
        msg: "Please enable Bluetooth to scan.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _startScan() {
    _devicesList.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.isNotEmpty && !_devicesList.contains(r.device)) {
          setState(() {
            _devicesList.add(r.device);
          });
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      Navigator.pushNamed(context, '/chat', arguments: device);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Connection failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a Device")),
      body: _devicesList.isEmpty
          ? const Center(child: Text("Scanning for devices..."))
          : ListView.separated(
              itemCount: _devicesList.length,
              itemBuilder: (context, index) {
                final device = _devicesList[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : "Unknown Device"),
                  onTap: () => _connectToDevice(device),
                );
              },
              separatorBuilder: (context, index) => const Divider(), // Adds a thin line between entries
            ),
    );
  }
}