// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveChatAdapter extends TypeAdapter<HiveChat> {
  @override
  final int typeId = 100;

  @override
  HiveChat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChat(
      id: fields[0] as int,
      creationDate: fields[1] as DateTime,
      model: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveChat obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creationDate)
      ..writeByte(2)
      ..write(obj.model);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
