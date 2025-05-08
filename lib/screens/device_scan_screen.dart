import 'package:flutter/material.dart';

// This screen will display nearby Bluetooth devices
class DeviceScanScreen extends StatelessWidget {
  const DeviceScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Devices'),
      ),
      body: const Center(
        child: Text('Device scanning UI coming soon...'),
      ),
    );
  }
}