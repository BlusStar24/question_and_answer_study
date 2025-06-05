import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'account_table.dart';

class MessageDBHelper {
  static final MessageDBHelper _instance = MessageDBHelper._internal();

  factory MessageDBHelper() => _instance;

  MessageDBHelper._internal();

  Future<int> _generateUniqueMessageId() async {
    final box = Hive.box<Message>('messages');
    if (box.isEmpty) return 1;

    final maxId = box.values
        .map((msg) => msg.messageId)
        .fold<int>(0, (prev, id) => id > prev ? id : prev);

    return maxId + 1;
  }

  Future<int> insertMessage(Message message) async {
    await DBHelper().initHive();
    final box = Hive.box<Message>('messages');

    try {
      final newId = await _generateUniqueMessageId();
      final newMessage = Message(
        messageId: newId,
        boxChatId: message.boxChatId,
        senderUserId: message.senderUserId,
        content: message.content,
        sentAt: message.sentAt,
        isFile: message.isFile,
        isDeleted: message.isDeleted,
      );
      await box.put(newId.toString(), newMessage);
      return newId;
    } catch (e) {
      throw Exception('Lỗi khi chèn tin nhắn: $e');
    }
  }

  Future<Message?> getMessageById(int id) async {
    await DBHelper().initHive();
    final box = Hive.box<Message>('messages');
    return box.get(id.toString());
  }

  Future<List<Message>> getMessagesByBoxChat(int boxChatId) async {
    await DBHelper().initHive();
    final box = Hive.box<Message>('messages');
    final filteredMessages = box.values
        .where((msg) => msg.boxChatId == boxChatId && !msg.isDeleted)
        .toList();

    filteredMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return filteredMessages;
  }
}
