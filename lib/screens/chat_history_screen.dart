import 'package:flutter/material.dart';
import 'package:blububb/messages/chat_storage.dart';

/// Displays the chat history of the selected user.
class ChatHistoryScreen extends StatefulWidget {
  final String username;

  const ChatHistoryScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  late final List messages;

  @override
  void initState() {
    super.initState();
    messages = ChatStorage.getMessages(widget.username)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Scroll to bottom after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History with ${widget.username}'),
      ),
      body: messages.isEmpty
          ? const Center(child: Text('No chat history available.'))
          : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                      8,
                      4,
                      8,
                      MediaQuery.of(context).viewPadding.bottom + 8,
                    ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isSentByMe = message.isSentByMe;

                return Align(
                  alignment: isSentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSentByMe
                          ? Colors.blueAccent
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isSentByMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
