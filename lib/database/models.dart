// models.dart
import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
enum UserRole {
  @HiveField(0)
  student,
  @HiveField(1)
  teacher,
  @HiveField(2)
  admin,
}

@HiveType(typeId: 1)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
  @HiveField(2)
  other,
}

@HiveType(typeId: 2)
enum RequestStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
  @HiveField(3)
  resolved,
}

@HiveType(typeId: 3)
class Account extends HiveObject {
  @HiveField(0)
  final int userId;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String password;
  @HiveField(3)
  final UserRole role;
  @HiveField(4)
  final bool isDeleted;

  Account({
    required this.userId,
    required this.username,
    required this.password,
    required this.role,
    this.isDeleted = false,
  });
}

@HiveType(typeId: 4)
class Student extends HiveObject {
  @HiveField(0)
  final int userId;
  @HiveField(1)
  final String studentCode;
  @HiveField(2)
  final String fullName;
  @HiveField(3)
  final Gender gender;
  @HiveField(4)
  final DateTime dateOfBirth;
  @HiveField(5)
  final String placeOfBirth;
  @HiveField(6)
  final String className;
  @HiveField(7)
  final int intakeYear;
  @HiveField(8)
  final String major;
  @HiveField(9)
  final String profileImage;
  @HiveField(10)
  final bool isDeleted;

  Student({
    required this.userId,
    required this.studentCode,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.className,
    required this.intakeYear,
    required this.major,
    required this.profileImage,
    this.isDeleted = false,
  });
}

@HiveType(typeId: 5)
class Teacher extends HiveObject {
  @HiveField(0)
  final int userId;
  @HiveField(1)
  final String teacherCode;
  @HiveField(2)
  final String fullName;
  @HiveField(3)
  final Gender gender;
  @HiveField(4)
  final DateTime dateOfBirth;
  @HiveField(5)
  final String profileImage;
  @HiveField(6)
  final bool isDeleted;

  Teacher({
    required this.userId,
    required this.teacherCode,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.profileImage,
    this.isDeleted = false,
  });
}

@HiveType(typeId: 6)
class Request extends HiveObject {
  @HiveField(0)
  final int requestId;
  @HiveField(1)
  final int studentUserId;
  @HiveField(2)
  final String questionType;
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String content;
  @HiveField(5)
  final String? attachedFilePath;
  @HiveField(6)
  final RequestStatus status;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final int? receiverUserId;
  @HiveField(9)
  final int? boxChatId;
  @HiveField(10)
  final bool isDeleted;

  Request({
    required this.requestId,
    required this.studentUserId,
    required this.questionType,
    required this.title,
    required this.content,
    this.attachedFilePath,
    required this.status,
    required this.createdAt,
    this.receiverUserId,
    this.boxChatId,
    this.isDeleted = false,
  });
}

@HiveType(typeId: 7)
class BoxChat extends HiveObject {
  @HiveField(0)
  final int boxChatId;
  @HiveField(1)
  final int requestId;
  @HiveField(2)
  final int senderUserId;
  @HiveField(3)
  final int receiverUserId;
  @HiveField(4)
  final bool isClosedByStudent;
  @HiveField(5)
  final bool isClosedByReceiver;
  @HiveField(6)
  final bool isDeleted;
  @HiveField(7)
  final DateTime createdAt;

  BoxChat({
    required this.boxChatId,
    required this.requestId,
    required this.senderUserId,
    required this.receiverUserId,
    this.isClosedByStudent = false,
    this.isClosedByReceiver = false,
    this.isDeleted = false,
    required this.createdAt,
  });
}

@HiveType(typeId: 8)
class Message extends HiveObject {
  @HiveField(0)
  final int messageId;
  @HiveField(1)
  final int boxChatId;
  @HiveField(2)
  final int senderUserId;
  @HiveField(3)
  final String content;
  @HiveField(4)
  final DateTime sentAt;
  @HiveField(5)
  final bool isFile;
  @HiveField(6)
  final bool isDeleted;

  Message({
    required this.messageId,
    required this.boxChatId,
    required this.senderUserId,
    required this.content,
    required this.sentAt,
    this.isFile = false,
    this.isDeleted = false,
  });
}

@HiveType(typeId: 9)
class Report extends HiveObject {
  @HiveField(0)
  final int reportId;
  @HiveField(1)
  final int reporterUserId;
  @HiveField(2)
  final int reportedUserId;
  @HiveField(3)
  final String reason;
  @HiveField(4)
  final DateTime reportedAt;
  @HiveField(5)
  final bool isHandled;

  Report({
    required this.reportId,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.reason,
    required this.reportedAt,
    this.isHandled = false,
  });
}

@HiveType(typeId: 10)
class BannedWord extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String word;

  BannedWord({
    required this.id,
    required this.word,
  });
}