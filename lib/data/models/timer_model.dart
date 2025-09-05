import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timer_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ScheduledSwitch {
  final String id;
  String desktopId;
  @TimeOfDayConverter()
  TimeOfDay time;
  List<int> weekdays; // Monday = 1, Sunday = 7

  ScheduledSwitch({
    required this.id,
    required this.desktopId,
    required this.time,
    required this.weekdays,
  });

  factory ScheduledSwitch.fromJson(Map<String, dynamic> json) => _$ScheduledSwitchFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduledSwitchToJson(this);
}

// Converter for TimeOfDay since it's not JSON serializable by default
class TimeOfDayConverter implements JsonConverter<TimeOfDay, String> {
  const TimeOfDayConverter();

  @override
  TimeOfDay fromJson(String json) {
    final parts = json.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  String toJson(TimeOfDay object) => '${object.hour}:${object.minute}';
}