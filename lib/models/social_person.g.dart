// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialPersonAdapter extends TypeAdapter<SocialPerson> {
  @override
  final int typeId = 2;

  @override
  SocialPerson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialPerson(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as bool,
      fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SocialPerson obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.personID)
      ..writeByte(1)
      ..write(obj.personUsername)
      ..writeByte(2)
      ..write(obj.personProfilePicURL)
      ..writeByte(3)
      ..write(obj.personCoverPicURL)
      ..writeByte(4)
      ..write(obj.isUserFollowing)
      ..writeByte(5)
      ..write(obj.hasUserBlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
