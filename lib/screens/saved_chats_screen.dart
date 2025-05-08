import 'package:flutter/material.dart';

// This screen will show previously saved chat logs
class SavedChatsScreen extends StatelessWidget {
  const SavedChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Chats'),
      ),
      body: const Center(
        child: Text('Saved chats will appear here...'),
      ),
    );
  }
}