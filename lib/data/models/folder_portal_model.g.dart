// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_portal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderPortalModel _$FolderPortalModelFromJson(Map<String, dynamic> json) =>
    FolderPortalModel(
      id: json['id'] as String,
      path: json['path'] as String,
      position: const OffsetConverter().fromJson(
        json['position'] as Map<String, dynamic>,
      ),
      size: json['size'] == null
          ? const Size(300, 200)
          : const SizeConverter().fromJson(
              json['size'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$FolderPortalModelToJson(FolderPortalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'position': const OffsetConverter().toJson(instance.position),
      'size': const SizeConverter().toJson(instance.size),
    };
