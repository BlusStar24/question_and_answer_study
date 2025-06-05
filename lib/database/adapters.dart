// adapters.dart
import 'package:hive/hive.dart';
import 'models.dart';

// Adapter for UserRole enum
class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 0;

  @override
  UserRole read(BinaryReader reader) {
    final index = reader.readByte();
    return UserRole.values[index];
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    writer.writeByte(obj.index);
  }
}

// Adapter for Gender enum
class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 1;

  @override
  Gender read(BinaryReader reader) {
    final index = reader.readByte();
    return Gender.values[index];
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    writer.writeByte(obj.index);
  }
}

// Adapter for RequestStatus enum
class RequestStatusAdapter extends TypeAdapter<RequestStatus> {
  @override
  final int typeId = 2;

  @override
  RequestStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return RequestStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, RequestStatus obj) {
    writer.writeByte(obj.index);
  }
}

// Adapter for Account
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
    this.userId = 0,
    required this.username,
    required this.password,
    required this.role,
    this.isDeleted = false,
  });
}

// Adapter for Student
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

// Adapter for Teacher
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

// Adapter for Request
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
    this.requestId = 0,
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

// Adapter for BoxChat
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
    this.boxChatId = 0,
    required this.requestId,
    required this.senderUserId,
    required this.receiverUserId,
    this.isClosedByStudent = false,
    this.isClosedByReceiver = false,
    this.isDeleted = false,
    required this.createdAt,
  });
}

// Adapter for Message
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
    this.messageId = 0,
    required this.boxChatId,
    required this.senderUserId,
    required this.content,
    required this.sentAt,
    this.isFile = false,
    this.isDeleted = false,
  });
}

// Adapter for Report
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
    this.reportId = 0,
    required this.reporterUserId,
    required this.reportedUserId,
    required this.reason,
    required this.reportedAt,
    this.isHandled = false,
  });
}

// Adapter for BannedWord
@HiveType(typeId: 10)
class BannedWord extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String word;

  BannedWord({this.id = 0, required this.word});
}
