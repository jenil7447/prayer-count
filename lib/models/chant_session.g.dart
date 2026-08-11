// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chant_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChantSessionAdapter extends TypeAdapter<ChantSession> {
  @override
  final int typeId = 0;

  @override
  ChantSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChantSession(
      name: fields[0] as String,
      count: fields[1] as int,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChantSession obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.count)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChantSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
