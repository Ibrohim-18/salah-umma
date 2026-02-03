// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ramadan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RamadanModelAdapter extends TypeAdapter<RamadanModel> {
  @override
  final int typeId = 4;

  @override
  RamadanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RamadanModel(
      fastingHistory: (fields[0] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<bool>())),
      totalMissedFasts: fields[1] as int,
      completedFasts: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RamadanModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.fastingHistory)
      ..writeByte(1)
      ..write(obj.totalMissedFasts)
      ..writeByte(2)
      ..write(obj.completedFasts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RamadanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
