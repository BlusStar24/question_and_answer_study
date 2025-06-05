// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 3;

  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      userId: fields[0] as int,
      username: fields[1] as String,
      password: fields[2] as String,
      role: fields[3] as UserRole,
      isDeleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 4;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      userId: fields[0] as int,
      studentCode: fields[1] as String,
      fullName: fields[2] as String,
      gender: fields[3] as Gender,
      dateOfBirth: fields[4] as DateTime,
      placeOfBirth: fields[5] as String,
      className: fields[6] as String,
      intakeYear: fields[7] as int,
      major: fields[8] as String,
      profileImage: fields[9] as String,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.studentCode)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.dateOfBirth)
      ..writeByte(5)
      ..write(obj.placeOfBirth)
      ..writeByte(6)
      ..write(obj.className)
      ..writeByte(7)
      ..write(obj.intakeYear)
      ..writeByte(8)
      ..write(obj.major)
      ..writeByte(9)
      ..write(obj.profileImage)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeacherAdapter extends TypeAdapter<Teacher> {
  @override
  final int typeId = 5;

  @override
  Teacher read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Teacher(
      userId: fields[0] as int,
      teacherCode: fields[1] as String,
      fullName: fields[2] as String,
      gender: fields[3] as Gender,
      dateOfBirth: fields[4] as DateTime,
      profileImage: fields[5] as String,
      isDeleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Teacher obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.teacherCode)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.dateOfBirth)
      ..writeByte(5)
      ..write(obj.profileImage)
      ..writeByte(6)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestAdapter extends TypeAdapter<Request> {
  @override
  final int typeId = 6;

  @override
  Request read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Request(
      requestId: fields[0] as int,
      studentUserId: fields[1] as int,
      questionType: fields[2] as String,
      title: fields[3] as String,
      content: fields[4] as String,
      attachedFilePath: fields[5] as String?,
      status: fields[6] as RequestStatus,
      createdAt: fields[7] as DateTime,
      receiverUserId: fields[8] as int?,
      boxChatId: fields[9] as int?,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Request obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.requestId)
      ..writeByte(1)
      ..write(obj.studentUserId)
      ..writeByte(2)
      ..write(obj.questionType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.attachedFilePath)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.receiverUserId)
      ..writeByte(9)
      ..write(obj.boxChatId)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BoxChatAdapter extends TypeAdapter<BoxChat> {
  @override
  final int typeId = 7;

  @override
  BoxChat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxChat(
      boxChatId: fields[0] as int,
      requestId: fields[1] as int,
      senderUserId: fields[2] as int,
      receiverUserId: fields[3] as int,
      isClosedByStudent: fields[4] as bool,
      isClosedByReceiver: fields[5] as bool,
      isDeleted: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BoxChat obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.boxChatId)
      ..writeByte(1)
      ..write(obj.requestId)
      ..writeByte(2)
      ..write(obj.senderUserId)
      ..writeByte(3)
      ..write(obj.receiverUserId)
      ..writeByte(4)
      ..write(obj.isClosedByStudent)
      ..writeByte(5)
      ..write(obj.isClosedByReceiver)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 8;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      messageId: fields[0] as int,
      boxChatId: fields[1] as int,
      senderUserId: fields[2] as int,
      content: fields[3] as String,
      sentAt: fields[4] as DateTime,
      isFile: fields[5] as bool,
      isDeleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.boxChatId)
      ..writeByte(2)
      ..write(obj.senderUserId)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.sentAt)
      ..writeByte(5)
      ..write(obj.isFile)
      ..writeByte(6)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 9;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      reportId: fields[0] as int,
      reporterUserId: fields[1] as int,
      reportedUserId: fields[2] as int,
      reason: fields[3] as String,
      reportedAt: fields[4] as DateTime,
      isHandled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.reporterUserId)
      ..writeByte(2)
      ..write(obj.reportedUserId)
      ..writeByte(3)
      ..write(obj.reason)
      ..writeByte(4)
      ..write(obj.reportedAt)
      ..writeByte(5)
      ..write(obj.isHandled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BannedWordAdapter extends TypeAdapter<BannedWord> {
  @override
  final int typeId = 10;

  @override
  BannedWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BannedWord(
      id: fields[0] as int,
      word: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BannedWord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannedWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 0;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.student;
      case 1:
        return UserRole.teacher;
      case 2:
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.student:
        writer.writeByte(0);
        break;
      case UserRole.teacher:
        writer.writeByte(1);
        break;
      case UserRole.admin:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 1;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
      case Gender.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestStatusAdapter extends TypeAdapter<RequestStatus> {
  @override
  final int typeId = 2;

  @override
  RequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RequestStatus.pending;
      case 1:
        return RequestStatus.approved;
      case 2:
        return RequestStatus.rejected;
      case 3:
        return RequestStatus.resolved;
      default:
        return RequestStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RequestStatus obj) {
    switch (obj) {
      case RequestStatus.pending:
        writer.writeByte(0);
        break;
      case RequestStatus.approved:
        writer.writeByte(1);
        break;
      case RequestStatus.rejected:
        writer.writeByte(2);
        break;
      case RequestStatus.resolved:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
