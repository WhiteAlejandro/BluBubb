import 'package:flutter/material.dart';
import 'device_scan_screen.dart';
import 'saved_chats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BluBubb'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder logo using an icon
            const Icon(
              Icons.bluetooth_audio,
              size: 100,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 30),
            // Connect to a Device button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeviceScanScreen()),
                );
              },
              child: const Text('Connect to a Device'),
            ),
            const SizedBox(height: 20),
            // Saved Chats button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SavedChatsScreen()),
                );
              },
              child: const Text('Saved Chats'),
            ),
          ],
        ),
      ),
    );
  }
}