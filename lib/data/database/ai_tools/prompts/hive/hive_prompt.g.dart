// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_prompt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HivePromptAdapter extends TypeAdapter<HivePrompt> {
  @override
  final int typeId = 102;

  @override
  HivePrompt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePrompt(
      id: fields[0] as int,
      title: fields[1] as String,
      prompt: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HivePrompt obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.prompt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePromptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
