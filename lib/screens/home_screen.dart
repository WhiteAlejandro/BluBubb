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
      appBar: AppBar(
        title: const Text(
          'BluBubb',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
          ),
        ),
      centerTitle: true,
    ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/blububb_logo.png',
              height: 250, // Adjust as needed
            ),

            const SizedBox(height: 64),

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