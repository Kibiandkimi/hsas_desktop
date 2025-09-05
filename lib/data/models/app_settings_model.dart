import 'package:json_annotation/json_annotation.dart';

part 'app_settings_model.g.dart';

@JsonSerializable()
class AppSettingsModel {
  double iconSizeScale;

  AppSettingsModel({
    this.iconSizeScale = 1.0, // Default scale
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => _$AppSettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsModelToJson(this);
}