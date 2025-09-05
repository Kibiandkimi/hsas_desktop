import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hsas_desktop/data/models/type_converters.dart';

part 'drawing_point_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DrawingPath {
  @OffsetConverter()
  List<Offset> points;

  @ColorConverter()
  final Color color;

  final double strokeWidth;

  DrawingPath({
    required this.points,
    this.color = Colors.white,
    this.strokeWidth = 4.0,
  });

  factory DrawingPath.fromJson(Map<String, dynamic> json) => _$DrawingPathFromJson(json);
  Map<String, dynamic> toJson() => _$DrawingPathToJson(this);
}