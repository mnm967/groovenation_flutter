// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_media_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SendMediaTaskAdapter extends TypeAdapter<SendMediaTask> {
  @override
  final int typeId = 7;

  @override
  SendMediaTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SendMediaTask(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SendMediaTask obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.receiverId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendMediaTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
