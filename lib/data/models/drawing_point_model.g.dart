// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrawingPath _$DrawingPathFromJson(Map<String, dynamic> json) => DrawingPath(
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  color: json['color'] == null
      ? Colors.white
      : const ColorConverter().fromJson((json['color'] as num).toInt()),
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 4.0,
);

Map<String, dynamic> _$DrawingPathToJson(DrawingPath instance) =>
    <String, dynamic>{
      'points': instance.points.map(const OffsetConverter().toJson).toList(),
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
    };
