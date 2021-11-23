// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 0;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      fields[0] as String?,
      fields[1] as SocialPerson?,
      fields[2] as int?,
    )..latestMessageJSON = (fields[3] as Map?)?.cast<dynamic, dynamic>();
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.conversationID)
      ..writeByte(1)
      ..write(obj.conversationPerson)
      ..writeByte(2)
      ..write(obj.newMessagesCount)
      ..writeByte(3)
      ..write(obj.latestMessageJSON);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
