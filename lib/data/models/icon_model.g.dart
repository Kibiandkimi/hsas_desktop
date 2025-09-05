// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IconModel _$IconModelFromJson(Map<String, dynamic> json) => IconModel(
  id: json['id'] as String,
  name: json['name'] as String,
  path: json['path'] as String,
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  type: $enumDecodeNullable(_$IconTypeEnumMap, json['type']) ?? IconType.file,
);

Map<String, dynamic> _$IconModelToJson(IconModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'path': instance.path,
  'type': _$IconTypeEnumMap[instance.type]!,
  'position': const OffsetConverter().toJson(instance.position),
};

const _$IconTypeEnumMap = {IconType.file: 'file', IconType.folder: 'folder'};
