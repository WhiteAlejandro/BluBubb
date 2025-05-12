import 'package:hive/hive.dart';
import 'chat_message.dart';

class ChatStorage {
  static const String boxName = 'chatBox';

  /// Save messages for a specific username.
  static Future<void> saveMessages(String username, List<ChatMessage> messages) async {
    final box = Hive.box<List>(boxName);
    await box.put(username, messages);
  }

  /// Retrieve stored messages for a specific username.
  static List<ChatMessage> getMessages(String username) {
    final box = Hive.box<List>(boxName);
    final storedMessages = box.get(username);
    if (storedMessages == null) return [];
    return List<ChatMessage>.from(storedMessages);
  }

  /// Optional: clear messages for a username.
  static Future<void> clearMessages(String username) async {
    final box = Hive.box<List>(boxName);
    await box.delete(username);
  }

  // Returns a list of all usernames (keys) in the Hive chat box
  static List<String> getAllUsernames() {
    final Box<List> box = Hive.box<List>(boxName);
    return box.keys.cast<String>().toList();
  }
}