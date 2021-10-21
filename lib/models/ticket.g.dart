// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TicketAdapter extends TypeAdapter<Ticket> {
  @override
  final int typeId = 8;

  @override
  Ticket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ticket(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as double,
      fields[6] as double,
      fields[7] as DateTime,
      fields[8] as DateTime,
      fields[9] as String,
      fields[10] as int,
      fields[11] as int,
      fields[12] as String,
      fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Ticket obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.ticketID)
      ..writeByte(1)
      ..write(obj.eventID)
      ..writeByte(2)
      ..write(obj.eventName)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.clubName)
      ..writeByte(5)
      ..write(obj.clubLatitude)
      ..writeByte(6)
      ..write(obj.clubLongitude)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.ticketType)
      ..writeByte(10)
      ..write(obj.noOfPeople)
      ..writeByte(11)
      ..write(obj.totalCost)
      ..writeByte(12)
      ..write(obj.encryptedQRTag)
      ..writeByte(13)
      ..write(obj.isScanned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
