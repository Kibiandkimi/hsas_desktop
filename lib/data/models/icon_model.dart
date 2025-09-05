import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hsas_desktop/data/models/type_converters.dart';

part 'icon_model.g.dart';

@JsonSerializable()
class IconModel {
  final String id;
  String name;
  String path;

  @OffsetConverter()
  Offset position;

  IconModel({
    required this.id,
    required this.name,
    required this.path,
    required this.position,
  });

  factory IconModel.fromJson(Map<String, dynamic> json) => _$IconModelFromJson(json);
  Map<String, dynamic> toJson() => _$IconModelToJson(this);
}