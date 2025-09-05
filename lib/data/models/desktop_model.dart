import 'package:json_annotation/json_annotation.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/data/models/folder_portal_model.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';

part 'desktop_model.g.dart';

enum ClickBehavior { singleClick, doubleClick }

@JsonSerializable(explicitToJson: true)
class DesktopSettingsModel {
  ClickBehavior clickBehavior;
  bool showShutdownButton;
  bool showSettingsButton;
  bool showAllAppsButton;
  bool showMinimizeButton;

  DesktopSettingsModel({
    this.clickBehavior = ClickBehavior.singleClick,
    this.showShutdownButton = true,
    this.showSettingsButton = true,
    this.showAllAppsButton = true,
    this.showMinimizeButton = true,
  });

  factory DesktopSettingsModel.fromJson(Map<String, dynamic> json) => _$DesktopSettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$DesktopSettingsModelToJson(this);
}


@JsonSerializable(explicitToJson: true)
class DesktopModel {
  final String id;
  String name;
  String? wallpaperPath;
  List<IconModel> icons;
  List<FolderPortalModel> portals;
  List<DrawingPath> drawingPaths;
  DesktopSettingsModel settings;

  // --- CONSTRUCTOR CORRECTED HERE ---
  DesktopModel({
    required this.id,
    required this.name,
    this.wallpaperPath,
    List<IconModel>? icons, // Use nullable types for constructor parameters
    List<FolderPortalModel>? portals,
    List<DrawingPath>? drawingPaths,
    DesktopSettingsModel? settings,
  })  : this.icons = icons ?? [], // If null, create a new MODIFIABLE list
        this.portals = portals ?? [], // If null, create a new MODIFIABLE list
        this.drawingPaths = drawingPaths ?? [], // If null, create a new MODIFIABLE list
        this.settings = settings ?? DesktopSettingsModel();

  factory DesktopModel.fromJson(Map<String, dynamic> json) => _$DesktopModelFromJson(json);
  Map<String, dynamic> toJson() => _$DesktopModelToJson(this);
}