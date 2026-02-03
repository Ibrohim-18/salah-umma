// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qada_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QadaModelAdapter extends TypeAdapter<QadaModel> {
  @override
  final int typeId = 3;

  @override
  QadaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QadaModel(
      totalMissedPrayers: fields[0] as int,
      completedPrayers: fields[1] as int,
      completedToday: (fields[2] as Map?)?.cast<String, int>(),
      lastUpdated: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QadaModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalMissedPrayers)
      ..writeByte(1)
      ..write(obj.completedPrayers)
      ..writeByte(2)
      ..write(obj.completedToday)
      ..writeByte(3)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QadaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
