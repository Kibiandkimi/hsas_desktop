// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DesktopSettingsModel _$DesktopSettingsModelFromJson(
  Map<String, dynamic> json,
) => DesktopSettingsModel(
  clickBehavior:
      $enumDecodeNullable(_$ClickBehaviorEnumMap, json['clickBehavior']) ??
      ClickBehavior.singleClick,
  showShutdownButton: json['showShutdownButton'] as bool? ?? true,
  showSettingsButton: json['showSettingsButton'] as bool? ?? true,
  showAllAppsButton: json['showAllAppsButton'] as bool? ?? true,
  showMinimizeButton: json['showMinimizeButton'] as bool? ?? true,
);

Map<String, dynamic> _$DesktopSettingsModelToJson(
  DesktopSettingsModel instance,
) => <String, dynamic>{
  'clickBehavior': _$ClickBehaviorEnumMap[instance.clickBehavior]!,
  'showShutdownButton': instance.showShutdownButton,
  'showSettingsButton': instance.showSettingsButton,
  'showAllAppsButton': instance.showAllAppsButton,
  'showMinimizeButton': instance.showMinimizeButton,
};

const _$ClickBehaviorEnumMap = {
  ClickBehavior.singleClick: 'singleClick',
  ClickBehavior.doubleClick: 'doubleClick',
};

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
  settings: json['settings'] == null
      ? null
      : DesktopSettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DesktopModelToJson(DesktopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'wallpaperPath': instance.wallpaperPath,
      'icons': instance.icons.map((e) => e.toJson()).toList(),
      'portals': instance.portals.map((e) => e.toJson()).toList(),
      'drawingPaths': instance.drawingPaths.map((e) => e.toJson()).toList(),
      'settings': instance.settings.toJson(),
    };
