import 'package:json_annotation/json_annotation.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/data/models/folder_portal_model.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';

part 'desktop_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DesktopModel {
  final String id;
  String name;
  String? wallpaperPath;
  List<IconModel> icons;
  List<FolderPortalModel> portals;
  List<DrawingPath> drawingPaths;

  DesktopModel({
    required this.id,
    required this.name,
    this.wallpaperPath,
    this.icons = const [],
    this.portals = const [],
    this.drawingPaths = const [],
  });

  factory DesktopModel.fromJson(Map<String, dynamic> json) => _$DesktopModelFromJson(json);
  Map<String, dynamic> toJson() => _$DesktopModelToJson(this);
}