import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart'; // Import for ClickBehavior
import 'package:hsas_desktop/data/models/type_converters.dart';

part 'folder_portal_model.g.dart';

enum SortType { nameAsc, nameDesc, dateAsc, dateDesc }

@JsonSerializable()
class FolderPortalModel {
  final String id;
  String path;
  SortType sortType;
  ClickBehavior clickBehavior; // Field for portal-specific click behavior

  @OffsetConverter()
  Offset position;

  @SizeConverter()
  Size size;

  FolderPortalModel({
    required this.id,
    required this.path,
    required this.position,
    this.size = const Size(300, 200),
    this.sortType = SortType.nameAsc,
    this.clickBehavior = ClickBehavior.doubleClick, // Default to double-click for portals
  });

  factory FolderPortalModel.fromJson(Map<String, dynamic> json) => _$FolderPortalModelFromJson(json);
  Map<String, dynamic> toJson() => _$FolderPortalModelToJson(this);
}