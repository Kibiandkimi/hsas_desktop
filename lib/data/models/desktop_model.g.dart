// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DesktopModel _$DesktopModelFromJson(Map<String, dynamic> json) => DesktopModel(
  id: json['id'] as String,
  name: json['name'] as String,
  wallpaperPath: json['wallpaperPath'] as String?,
  icons:
      (json['icons'] as List<dynamic>?)
          ?.map((e) => IconModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  portals:
      (json['portals'] as List<dynamic>?)
          ?.map((e) => FolderPortalModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  drawingPaths:
      (json['drawingPaths'] as List<dynamic>?)
          ?.map((e) => DrawingPath.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DesktopModelToJson(DesktopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'wallpaperPath': instance.wallpaperPath,
      'icons': instance.icons.map((e) => e.toJson()).toList(),
      'portals': instance.portals.map((e) => e.toJson()).toList(),
      'drawingPaths': instance.drawingPaths.map((e) => e.toJson()).toList(),
    };
