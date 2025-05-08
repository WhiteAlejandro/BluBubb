import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class ChatScreen extends StatelessWidget {
  final Device device;

  const ChatScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${device.deviceName}'),
      ),
      body: Center(
        child: Text(
          'Chat screen for ${device.deviceName}\n\n(To be implemented)',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}