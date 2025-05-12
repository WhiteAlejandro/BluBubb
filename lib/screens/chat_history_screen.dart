import 'package:flutter/material.dart';
import 'package:blububb/messages/chat_storage.dart';

/// Displays a list of users with stored chat history.
/// Each item navigates to a screen showing that chat.
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  late List<String> _usernamesWithChats;

  @override
  void initState() {
    super.initState();
    _loadChatUsers();
  }

  /// Loads all usernames (keys) that have saved chat history in Hive.
  void _loadChatUsers() {
    final allChats = ChatStorage.getAllUsernames();
    setState(() {
      _usernamesWithChats = allChats;
    });
  }

  /// Navigates to a screen showing chat history with the selected user.
  void _navigateToChatHistory(String username) {
    Navigator.pushNamed(
      context,
      '/chat-history-view',
      arguments: username,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat History')),
      body: _usernamesWithChats.isEmpty
          ? const Center(child: Text('No chat history found.'))
          : ListView.builder(
              itemCount: _usernamesWithChats.length,
              itemBuilder: (context, index) {
                final username = _usernamesWithChats[index];
                return ListTile(
                  title: Text(username),
                  leading: const Icon(Icons.person),
                  onTap: () => _navigateToChatHistory(username),
                );
              },
            ),
    );
  }
}