import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import 'models.dart';
import 'account_table.dart';

class StudentDBHelper {
  static final StudentDBHelper _instance = StudentDBHelper._internal();

  factory StudentDBHelper() => _instance;

  StudentDBHelper._internal();

  String generateStudentCode() {
    final random = Random();
    int randomNumber = random.nextInt(10000);
    String fourDigits = randomNumber.toString().padLeft(4, '0');
    return '2001$fourDigits';
  }

  Future<bool> isStudentCodeExists(String code) async {
    await DBHelper().initHive();
    final box = Hive.box<Student>('students');
    return box.values.any((student) => student.studentCode == code);
  }

  Future<Student?> insertStudent(Student student) async {
    await DBHelper().initHive();
    final studentBox = Hive.box<Student>('students');
    final dbHelper = DBHelper();

    try {
      if (student.fullName.isEmpty ||
          student.placeOfBirth.isEmpty ||
          student.className.isEmpty ||
          student.major.isEmpty ||
          student.dateOfBirth == 0) {
        throw Exception('Các trường bắt buộc không được để trống');
      }

      String studentCode;
      do {
        studentCode = generateStudentCode();
      } while (await isStudentCodeExists(studentCode));

      final account = Account(
        userId: 0, // Will be replaced by generated ID
        username: studentCode,
        password: 'huit$studentCode',
        role: UserRole.student,
        isDeleted: false,
      );

      int newUserId = await dbHelper.insertAccount(account);
      if (newUserId <= 0) {
        throw Exception('Không thể tạo tài khoản, userId: $newUserId');
      }

      final newStudent = Student(
        userId: newUserId,
        studentCode: studentCode,
        fullName: student.fullName,
        gender: student.gender,
        dateOfBirth: student.dateOfBirth,
        placeOfBirth: student.placeOfBirth,
        className: student.className,
        intakeYear: student.intakeYear,
        major: student.major,
        profileImage: student.profileImage.isEmpty ? '' : student.profileImage,
        isDeleted: false,
      );

      await studentBox.put(studentCode, newStudent);

      print("Student created:");
      print("StudentCode: ${newStudent.studentCode}");
      print("Username: ${account.username}");
      print("Password: ${account.password}");
      print("UserId: ${newStudent.userId}");
      print("FullName: ${newStudent.fullName}");

      return newStudent;
    } catch (e) {
      throw Exception('Lỗi khi tạo student/account: $e');
    }
  }

  Future<Student?> getStudentByCode(String studentCode) async {
    await DBHelper().initHive();
    final box = Hive.box<Student>('students');
    final student = box.get(studentCode);
    if (student != null && !student.isDeleted) {
      return student;
    }
    return null;
  }

  Future<Student?> getStudentByUserId(int userId) async {
    await DBHelper().initHive();
    final box = Hive.box<Student>('students');
    try {
      return box.values.firstWhere(
        (student) => student.userId == userId && !student.isDeleted,
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> updateStudent(Student student) async {
    await DBHelper().initHive();
    final box = Hive.box<Student>('students');
    try {
      await box.put(student.studentCode, student);
      return 1;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật sinh viên: $e');
    }
  }

  Future<int> softDeleteStudent(String studentCode) async {
    await DBHelper().initHive();
    final box = Hive.box<Student>('students');
    try {
      final student = box.get(studentCode);
      if (student != null) {
        final updatedStudent = Student(
          userId: student.userId,
          studentCode: student.studentCode,
          fullName: student.fullName,
          gender: student.gender,
          dateOfBirth: student.dateOfBirth,
          placeOfBirth: student.placeOfBirth,
          className: student.className,
          intakeYear: student.intakeYear,
          major: student.major,
          profileImage: student.profileImage,
          isDeleted: true,
        );
        await box.put(studentCode, updatedStudent);
        return 1;
      }
      return 0;
    } catch (e) {
      throw Exception('Lỗi khi xóa mềm sinh viên: $e');
    }
  }

  Future<List<Student>> getAllStudents() async {
    await DBHelper().initHive();
    final box = Hive.box<Student>('students');
    try {
      final students = box.values
          .where((student) => !student.isDeleted)
          .toList();
      print('Students: $students');
      return students;
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sinh viên: $e');
    }
  }
}
