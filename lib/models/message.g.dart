// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      fields[0] as String,
      fields[1] as String,
      fields[3] as String,
      fields[4] as DateTime,
      fields[5] as SocialPerson,
      fields[6] as String,
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.messageID)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.messageDateTime)
      ..writeByte(5)
      ..write(obj.sender)
      ..writeByte(6)
      ..write(obj.receiverId)
      ..writeByte(7)
      ..write(obj.messageStatus);
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

class TextMessageAdapter extends TypeAdapter<TextMessage> {
  @override
  final int typeId = 3;

  @override
  TextMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextMessage(
      fields[0] as String,
      fields[1] as String,
      fields[4] as DateTime,
      fields[5] as SocialPerson,
      fields[8] as String,
      fields[6] as String,
    )..messageStatus = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, TextMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(8)
      ..write(obj.text)
      ..writeByte(0)
      ..write(obj.messageID)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.messageDateTime)
      ..writeByte(5)
      ..write(obj.sender)
      ..writeByte(6)
      ..write(obj.receiverId)
      ..writeByte(7)
      ..write(obj.messageStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaMessageAdapter extends TypeAdapter<MediaMessage> {
  @override
  final int typeId = 4;

  @override
  MediaMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaMessage(
      fields[0] as String,
      fields[1] as String,
      fields[4] as DateTime,
      fields[5] as SocialPerson,
      fields[8] as String,
      fields[6] as String,
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MediaMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(8)
      ..write(obj.mediaURL)
      ..writeByte(0)
      ..write(obj.messageID)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.messageDateTime)
      ..writeByte(5)
      ..write(obj.sender)
      ..writeByte(6)
      ..write(obj.receiverId)
      ..writeByte(7)
      ..write(obj.messageStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SocialPostMessageAdapter extends TypeAdapter<SocialPostMessage> {
  @override
  final int typeId = 5;

  @override
  SocialPostMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialPostMessage(
      fields[0] as String,
      fields[1] as String,
      fields[4] as DateTime,
      fields[5] as SocialPerson,
      fields[8] as SocialPost,
      fields[6] as String,
    )..messageStatus = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, SocialPostMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(8)
      ..write(obj.post)
      ..writeByte(0)
      ..write(obj.messageID)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.messageDateTime)
      ..writeByte(5)
      ..write(obj.sender)
      ..writeByte(6)
      ..write(obj.receiverId)
      ..writeByte(7)
      ..write(obj.messageStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPostMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
