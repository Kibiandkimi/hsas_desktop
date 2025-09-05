import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hsas_desktop/data/models/type_converters.dart';

part 'folder_portal_model.g.dart';

@JsonSerializable()
class FolderPortalModel {
  final String id;
  String path;

  @OffsetConverter()
  Offset position;

  @SizeConverter()
  Size size;

  FolderPortalModel({
    required this.id,
    required this.path,
    required this.position,
    this.size = const Size(300, 200),
  });

  factory FolderPortalModel.fromJson(Map<String, dynamic> json) => _$FolderPortalModelFromJson(json);
  Map<String, dynamic> toJson() => _$FolderPortalModelToJson(this);
}