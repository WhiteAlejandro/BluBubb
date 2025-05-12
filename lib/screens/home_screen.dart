import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();

  void _navigateToScan() {
    final username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/scan',
        arguments: username,
      );
    }
  }

  void _navigateToSavedChats() {
    Navigator.pushNamed(context, '/userHistory');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BluBubb')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Temporary Bluetooth-style logo
            const Icon(Icons.bluetooth, size: 100, color: Colors.blue),

            const SizedBox(height: 32),

            // Text field with hint text
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _navigateToScan,
              child: const Text('Connect to a Device'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _navigateToSavedChats,
              child: const Text('Chat History'),
            ),
          ],
        ),
      ),
    );
  }
}