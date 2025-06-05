import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'account_table.dart';

class ChatboxDBHelper {
  static final ChatboxDBHelper _instance = ChatboxDBHelper._internal();

  factory ChatboxDBHelper() => _instance;

  ChatboxDBHelper._internal();

  Future<int> _generateUniqueBoxChatId() async {
    final box = Hive.box<BoxChat>('box_chats');
    final items = box.values.toList();
    if (items.isEmpty) return 1;
    final maxId = items.fold<int>(
      0,
      (max, item) => max > item.boxChatId ? max : item.boxChatId,
    );
    return maxId + 1;
  }

  Future<int> insertBoxChat(BoxChat boxChat) async {
    await DBHelper().initHive();
    final box = Hive.box<BoxChat>('box_chats');
    try {
      final newId = await _generateUniqueBoxChatId();
      final newBoxChat = BoxChat(
        boxChatId: newId,
        requestId: boxChat.requestId,
        senderUserId: boxChat.senderUserId,
        receiverUserId: boxChat.receiverUserId,
        isClosedByStudent: boxChat.isClosedByStudent,
        isClosedByReceiver: boxChat.isClosedByReceiver,
        isDeleted: boxChat.isDeleted,
        createdAt: boxChat.createdAt,
      );
      await box.put(newId.toString(), newBoxChat);
      return newId;
    } catch (e) {
      throw Exception('Lỗi khi chèn box chat: $e');
    }
  }

  Future<BoxChat> getBoxChatByRequestId(int requestId) async {
    await DBHelper().initHive();
    final box = Hive.box<BoxChat>('box_chats');
    final boxChat = box.values.firstWhere(
      (boxChat) => boxChat.requestId == requestId && !boxChat.isDeleted,
      orElse: () =>
          throw Exception('No box chat found for requestId: $requestId'),
    );
    return boxChat;
  }

  Future<List<BoxChat>> getBoxChatsByUser(int userId) async {
    await DBHelper().initHive();
    final box = Hive.box<BoxChat>('box_chats');
    return box.values
        .where(
          (boxChat) =>
              (boxChat.senderUserId == userId ||
                  boxChat.receiverUserId == userId) &&
              !boxChat.isDeleted,
        )
        .toList()
      ..sort((a, b) => b.boxChatId.compareTo(a.boxChatId));
  }

  Future<void> insertReport(Report report) async {
    await DBHelper().initHive();
    final box = Hive.box<Report>('reports');
    try {
      final newId = box.values.isEmpty
          ? 1
          : box.values.map((r) => r.reportId).reduce((a, b) => a > b ? a : b) +
                1;
      final newReport = Report(
        reportId: newId,
        reporterUserId: report.reporterUserId,
        reportedUserId: report.reportedUserId,
        reason: report.reason,
        reportedAt: report.reportedAt,
        isHandled: report.isHandled,
      );
      await box.put(newId.toString(), newReport);
    } catch (e) {
      throw Exception('Lỗi khi chèn báo cáo: $e');
    }
  }

  Future<List<Report>> getReports() async {
    await DBHelper().initHive();
    final box = Hive.box<Report>('reports');
    return box.values.toList();
  }

  Future<void> deleteBoxChat(int boxChatId) async {
    await DBHelper().initHive();
    final boxChatBox = Hive.box<BoxChat>('box_chats');
    final messageBox = Hive.box<Message>('messages');
    try {
      final boxChat = boxChatBox.get(boxChatId.toString());
      if (boxChat != null) {
        final updatedBoxChat = BoxChat(
          boxChatId: boxChat.boxChatId,
          requestId: boxChat.requestId,
          senderUserId: boxChat.senderUserId,
          receiverUserId: boxChat.receiverUserId,
          isClosedByStudent: boxChat.isClosedByStudent,
          isClosedByReceiver: boxChat.isClosedByReceiver,
          isDeleted: true,
          createdAt: boxChat.createdAt,
        );
        await boxChatBox.put(boxChatId.toString(), updatedBoxChat);

        final messages = messageBox.values
            .where((message) => message.boxChatId == boxChatId)
            .toList();
        for (var message in messages) {
          final updatedMessage = Message(
            messageId: message.messageId,
            boxChatId: message.boxChatId,
            senderUserId: message.senderUserId,
            content: message.content,
            sentAt: message.sentAt,
            isFile: message.isFile,
            isDeleted: true,
          );
          await messageBox.put(message.messageId.toString(), updatedMessage);
        }
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa box chat: $e');
    }
  }
}
