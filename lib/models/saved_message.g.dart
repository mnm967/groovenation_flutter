// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedMessageAdapter extends TypeAdapter<SavedMessage> {
  @override
  final int typeId = 6;

  @override
  SavedMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMessage(
      fields[0] as String,
      (fields[1] as Map)?.cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedMessage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.conversationId)
      ..writeByte(1)
      ..write(obj.messageJSON);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
