import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import 'models.dart';
import 'account_table.dart';

class TeacherDBHelper {
  static final TeacherDBHelper _instance = TeacherDBHelper._internal();

  factory TeacherDBHelper() => _instance;

  TeacherDBHelper._internal();

  String generateTeacherCode() {
    final random = Random();
    int randomNumber = random.nextInt(10000);
    String fourDigits = randomNumber.toString().padLeft(4, '0');
    return '3001$fourDigits';
  }

  Future<bool> isTeacherCodeExists(String code) async {
    await DBHelper().initHive();
    final box = Hive.box<Teacher>('teachers');
    return box.values.any((teacher) => teacher.teacherCode == code);
  }

  Future<Teacher?> insertTeacher(Teacher teacher) async {
    await DBHelper().initHive();
    final teacherBox = Hive.box<Teacher>('teachers');
    final dbHelper = DBHelper();

    try {
      if (teacher.fullName.isEmpty || teacher.dateOfBirth == 0) {
        throw Exception('Các trường bắt buộc không được để trống');
      }

      String teacherCode;
      do {
        teacherCode = generateTeacherCode();
      } while (await isTeacherCodeExists(teacherCode));

      final account = Account(
        userId: 0, // Will be replaced by generated ID
        username: teacherCode,
        password: 'huit$teacherCode',
        role: UserRole.teacher,
        isDeleted: false,
      );

      int newUserId = await dbHelper.insertAccount(account);
      if (newUserId <= 0) {
        throw Exception('Không thể tạo tài khoản, userId: $newUserId');
      }

      final newTeacher = Teacher(
        userId: newUserId,
        teacherCode: teacherCode,
        fullName: teacher.fullName,
        gender: teacher.gender,
        dateOfBirth: teacher.dateOfBirth,
        profileImage: teacher.profileImage.isEmpty ? '' : teacher.profileImage,
        isDeleted: false,
      );

      await teacherBox.put(teacherCode, newTeacher);

      print("Teacher created:");
      print("TeacherCode: ${newTeacher.teacherCode}");
      print("Username: ${account.username}");
      print("Password: ${account.password}");
      print("UserId: ${newTeacher.userId}");
      print("FullName: ${newTeacher.fullName}");

      return newTeacher;
    } catch (e) {
      throw Exception('Lỗi khi tạo teacher/account: $e');
    }
  }

  Future<Teacher?> getTeacherByCode(String teacherCode) async {
    await DBHelper().initHive();
    final box = Hive.box<Teacher>('teachers');
    final teacher = box.get(teacherCode);
    if (teacher != null && !teacher.isDeleted) {
      return teacher;
    }
    return null;
  }

  Future<Teacher?> getTeacherByUserId(int userId) async {
    await DBHelper().initHive();
    final box = Hive.box<Teacher>('teachers');
    try {
      return box.values.firstWhere(
        (teacher) => teacher.userId == userId && !teacher.isDeleted,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> updateTeacher(Teacher teacher) async {
    await DBHelper().initHive();
    final box = Hive.box<Teacher>('teachers');
    try {
      await box.put(teacher.teacherCode, teacher);
      return 1;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giáo viên: $e');
    }
  }

  Future<int> softDeleteTeacher(String teacherCode) async {
    await DBHelper().initHive();
    final box = Hive.box<Teacher>('teachers');
    try {
      final teacher = box.get(teacherCode);
      if (teacher != null) {
        final updatedTeacher = Teacher(
          userId: teacher.userId,
          teacherCode: teacher.teacherCode,
          fullName: teacher.fullName,
          gender: teacher.gender,
          dateOfBirth: teacher.dateOfBirth,
          profileImage: teacher.profileImage,
          isDeleted: true,
        );
        await box.put(teacherCode, updatedTeacher);
        return 1;
      }
      return 0;
    } catch (e) {
      throw Exception('Lỗi khi xóa mềm giáo viên: $e');
    }
  }

  Future<List<Teacher>> getAllTeachers() async {
    await DBHelper().initHive();
    final box = Hive.box<Teacher>('teachers');
    try {
      final teachers = box.values
          .where((teacher) => !teacher.isDeleted)
          .toList();
      print('Teachers: $teachers');
      return teachers;
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách giáo viên: $e');
    }
  }
}
