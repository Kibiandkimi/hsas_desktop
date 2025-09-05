// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduledSwitch _$ScheduledSwitchFromJson(Map<String, dynamic> json) =>
    ScheduledSwitch(
      id: json['id'] as String,
      desktopId: json['desktopId'] as String,
      time: const TimeOfDayConverter().fromJson(json['time'] as String),
      weekdays: (json['weekdays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ScheduledSwitchToJson(ScheduledSwitch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'desktopId': instance.desktopId,
      'time': const TimeOfDayConverter().toJson(instance.time),
      'weekdays': instance.weekdays,
    };
