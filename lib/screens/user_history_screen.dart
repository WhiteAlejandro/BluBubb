import 'package:flutter/material.dart';
import 'package:blububb/messages/chat_storage.dart';

/// Displays a list of users with whom chats are stored.
class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  late List<String> usernames;

  @override
  void initState() {
    super.initState();
    usernames = ChatStorage.getAllUsernames(); // Assumes this method exists
  }

  void _deleteChat(String username) async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Chat',
      content: 'Delete chat history with "$username"?',
    );
    if (confirmed) {
      ChatStorage.deleteMessagesForUser(username); // Assumes this method exists
      setState(() {
        usernames.remove(username);
      });
    }
  }

  void _deleteAllChats() async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete All Chats',
      content: 'Are you sure you want to delete ALL chat histories?',
    );
    if (confirmed) {
      ChatStorage.clearAllMessages(); // Assumes this method exists
      setState(() {
        usernames.clear();
      });
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String content,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete All',
            onPressed: usernames.isEmpty ? null : _deleteAllChats,
          ),
        ],
      ),
      body: usernames.isEmpty
          ? const Center(child: Text('No chat history found.'))
          : ListView.builder(
              itemCount: usernames.length,
              itemBuilder: (context, index) {
                final username = usernames[index];
                return Dismissible(
                  key: Key(username),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    final confirmed = await _showConfirmDialog(
                      title: 'Delete Chat',
                      content: 'Delete chat history with "$username"?',
                    );
                    if (confirmed) {
                      ChatStorage.deleteMessagesForUser(username);
                      setState(() {
                        usernames.remove(username);
                      });
                    }
                    return confirmed;
                  },
                  onDismissed: (_) => _deleteChat(username),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(username),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chatHistory',
                        arguments: username,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}