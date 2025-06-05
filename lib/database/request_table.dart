import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';
import 'box_chat_table.dart' as boxChat;
import 'account_table.dart';

class RequestDBHelper {
  static final RequestDBHelper _instance = RequestDBHelper._internal();

  factory RequestDBHelper() => _instance;

  RequestDBHelper._internal();

  Future<int> _generateUniqueRequestId() async {
    final box = Hive.box<Request>('requests');
    final items = box.values.toList();
    if (items.isEmpty) return 1;
    final maxId = items.fold<int>(
      0,
      (max, item) => max > item.requestId ? max : item.requestId,
    );
    return maxId + 1;
  }

  Future<int> insertRequest(Request request) async {
    await DBHelper().initHive();
    final box = Hive.box<Request>('requests');
    try {
      final newId = await _generateUniqueRequestId();
      final newRequest = Request(
        requestId: newId,
        studentUserId: request.studentUserId,
        questionType: request.questionType,
        title: request.title,
        content: request.content,
        attachedFilePath: request.attachedFilePath,
        status: request.status,
        createdAt: request.createdAt,
        receiverUserId: request.receiverUserId,
        boxChatId: request.boxChatId,
        isDeleted: request.isDeleted,
      );
      await box.put(newId.toString(), newRequest);
      return newId;
    } catch (e) {
      throw Exception('Lỗi khi chèn yêu cầu: $e');
    }
  }

  Future<void> approveRequest(int requestId, int teacherUserId) async {
    await DBHelper().initHive();
    final requestBox = Hive.box<Request>('requests');
    final boxChatBox = Hive.box<BoxChat>('box_chats');
    try {
      final request = requestBox.get(requestId.toString());
      if (request == null) {
        throw Exception('Yêu cầu không tồn tại: $requestId');
      }

      final updatedRequest = Request(
        requestId: request.requestId,
        studentUserId: request.studentUserId,
        questionType: request.questionType,
        title: request.title,
        content: request.content,
        attachedFilePath: request.attachedFilePath,
        status: RequestStatus.approved,
        createdAt: request.createdAt,
        receiverUserId: teacherUserId,
        boxChatId: request.boxChatId,
        isDeleted: request.isDeleted,
      );

      await requestBox.put(requestId.toString(), updatedRequest);

      BoxChat? existingBoxChat;
      try {
        existingBoxChat = boxChatBox.values.firstWhere(
          (boxChat) => boxChat.requestId == requestId,
        );
      } catch (_) {
        existingBoxChat = null;
      }

      if (existingBoxChat == null) {
        final boxChatId = await boxChat.ChatboxDBHelper().insertBoxChat(
          BoxChat(
            boxChatId: 0, // Will be replaced by generated ID
            requestId: requestId,
            senderUserId: request.studentUserId,
            receiverUserId: teacherUserId,
            isClosedByStudent: false,
            isClosedByReceiver: false,
            isDeleted: false,
            createdAt: DateTime.now(),
          ),
        );

        final finalRequest = Request(
          requestId: request.requestId,
          studentUserId: request.studentUserId,
          questionType: request.questionType,
          title: request.title,
          content: request.content,
          attachedFilePath: request.attachedFilePath,
          status: RequestStatus.approved,
          createdAt: request.createdAt,
          receiverUserId: teacherUserId,
          boxChatId: boxChatId,
          isDeleted: request.isDeleted,
        );

        await requestBox.put(requestId.toString(), finalRequest);
      }
    } catch (e) {
      throw Exception('Lỗi khi phê duyệt yêu cầu: $e');
    }
  }

  Future<int> updateRequestStatus(int requestId, RequestStatus status) async {
    await DBHelper().initHive();
    final box = Hive.box<Request>('requests');
    try {
      final request = box.get(requestId.toString());
      if (request != null) {
        final updatedRequest = Request(
          requestId: request.requestId,
          studentUserId: request.studentUserId,
          questionType: request.questionType,
          title: request.title,
          content: request.content,
          attachedFilePath: request.attachedFilePath,
          status: status,
          createdAt: request.createdAt,
          receiverUserId: request.receiverUserId,
          boxChatId: request.boxChatId,
          isDeleted: request.isDeleted,
        );
        await box.put(requestId.toString(), updatedRequest);
        return 1;
      }
      return 0;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái yêu cầu: $e');
    }
  }

  Future<List<Request>> getRequestsByStudent(int studentUserId) async {
    await DBHelper().initHive();
    final box = Hive.box<Request>('requests');
    return box.values
        .where(
          (request) =>
              request.studentUserId == studentUserId && !request.isDeleted,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> insertBannedWord(BannedWord bannedWord) async {
    await DBHelper().initHive();
    final box = Hive.box<BannedWord>('banned_words');
    try {
      final newId = box.values.isEmpty
          ? 1
          : box.values.map((bw) => bw.id).reduce((a, b) => a > b ? a : b) + 1;
      final newBannedWord = BannedWord(id: newId, word: bannedWord.word);
      await box.put(newId.toString(), newBannedWord);
    } catch (e) {
      throw Exception('Lỗi khi chèn từ bị cấm: $e');
    }
  }

  Future<List<BannedWord>> getBannedWords() async {
    await DBHelper().initHive();
    final box = Hive.box<BannedWord>('banned_words');
    return box.values.toList();
  }

  Future<List<Request>> getRequestsByStatus(String status) async {
    await DBHelper().initHive();
    final box = Hive.box<Request>('requests');
    final statusEnum = RequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => throw Exception('Invalid status: $status'),
    );
    return box.values
        .where((request) => request.status == statusEnum && !request.isDeleted)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Request>> getRequestsByTeacher(int teacherId) async {
    await DBHelper().initHive();
    final box = Hive.box<Request>('requests');
    return box.values
        .where(
          (request) =>
              request.receiverUserId == teacherId &&
              request.status == RequestStatus.approved &&
              !request.isDeleted,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
