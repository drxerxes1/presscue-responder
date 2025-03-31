// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_url.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaseUrlModelAdapter extends TypeAdapter<BaseUrlModel> {
  @override
  final int typeId = 2;

  @override
  BaseUrlModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BaseUrlModel(
      baseUrl: fields[0] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, BaseUrlModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.baseUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseUrlModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
