import 'package:hive/hive.dart';

part 'chat_message.g.dart'; // Needed for generated adapter

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String content;

  @HiveField(1)
  bool isSentByMe;

  @HiveField(2)
  DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isSentByMe,
    required this.timestamp,
  });
}