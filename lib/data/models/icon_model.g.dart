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
);

Map<String, dynamic> _$IconModelToJson(IconModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'path': instance.path,
  'position': const OffsetConverter().toJson(instance.position),
};
