import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static bool _isInitialized = false;

  Future<void> initHive() async {
    if (_isInitialized) return;
    await Hive.openBox<Account>('accounts');
    await Hive.openBox<Student>('students');
    await Hive.openBox<Teacher>('teachers');
    await Hive.openBox<Request>('requests');
    await Hive.openBox<BoxChat>('box_chats');
    await Hive.openBox<Message>('messages');
    await Hive.openBox<Report>('reports');
    await Hive.openBox<BannedWord>('banned_words');
    _isInitialized = true;
    print('Hive boxes opened in DBHelper');
  }

  Future<int> _generateUniqueId<T>(Box<T> box) async {
    final items = box.values.toList();
    if (items.isEmpty) return 1;
    final maxId = items.fold<int>(
      0,
      (max, item) =>
          max > (item as dynamic).userId ? max : (item as dynamic).userId,
    );
    return maxId + 1;
  }

  Future<int> insertAccount(Account account) async {
    await initHive();
    final box = Hive.box<Account>('accounts');
    try {
      final newId = await _generateUniqueId(box);
      final newAccount = Account(
        userId: newId,
        username: account.username,
        password: account.password,
        role: account.role,
        isDeleted: account.isDeleted,
      );
      await box.put(newId.toString(), newAccount);
      print('Inserted account: ${newAccount.username} with userId: $newId');
      return newId;
    } catch (e) {
      throw Exception('Lỗi khi chèn tài khoản: $e');
    }
  }

  Future<List<Teacher>> getTeachers() async {
    await initHive();
    final box = Hive.box<Teacher>('teachers');
    return box.values.where((teacher) => !teacher.isDeleted).toList();
  }

  Future<Account?> getAccountById(int userId) async {
    await initHive();
    final box = Hive.box<Account>('accounts');
    final account = box.get(userId.toString());
    if (account != null && !account.isDeleted) {
      return account;
    }
    return null;
  }

  Future<int> updateAccount(Account account) async {
    await initHive();
    final box = Hive.box<Account>('accounts');
    try {
      await box.put(account.userId.toString(), account);
      return 1;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật tài khoản: $e');
    }
  }

  Future<int> softDeleteAccount(int userId) async {
    await initHive();
    final box = Hive.box<Account>('accounts');
    try {
      final account = box.get(userId.toString());
      if (account != null) {
        final updatedAccount = Account(
          userId: account.userId,
          username: account.username,
          password: account.password,
          role: account.role,
          isDeleted: true,
        );
        await box.put(userId.toString(), updatedAccount);
        return 1;
      }
      return 0;
    } catch (e) {
      throw Exception('Lỗi khi xóa mềm tài khoản: $e');
    }
  }

  Future<List<Account>> getAllAccounts() async {
    await initHive();
    final box = Hive.box<Account>('accounts');
    try {
      return box.values.where((account) => !account.isDeleted).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách tài khoản: $e');
    }
  }

  Future<Account?> getAccountByUsername(String username) async {
    await initHive();
    final box = Hive.box<Account>('accounts');
    try {
      final account = box.values.firstWhere(
        (acc) => acc.username == username && !acc.isDeleted,
      );
      return account;
    } catch (e) {
      // Nếu không tìm thấy, firstWhere sẽ ném StateError
      if (e is StateError) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> debugDatabase() async {
    await initHive();
    try {
      final accounts = Hive.box<Account>('accounts').values.toList();
      final students = Hive.box<Student>('students').values.toList();
      final teachers = Hive.box<Teacher>('teachers').values.toList();
      final requests = Hive.box<Request>('requests').values.toList();
      final boxChats = Hive.box<BoxChat>('box_chats').values.toList();
      final messages = Hive.box<Message>('messages').values.toList();
      final reports = Hive.box<Report>('reports').values.toList();
      final bannedWords = Hive.box<BannedWord>('banned_words').values.toList();
      print('Accounts: $accounts');
      print('Students: $students');
      print('Teachers: $teachers');
      print('Requests: $requests');
      print('Box Chats: $boxChats');
      print('Messages: $messages');
      print('Reports: $reports');
      print('Banned Words: $bannedWords');
    } catch (e) {
      throw Exception('Lỗi khi debug database: $e');
    }
  }
}
