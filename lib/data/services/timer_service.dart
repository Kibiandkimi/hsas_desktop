import 'dart:async'; // Corrected import
import 'package:flutter/material.dart'; // Corrected import
import 'package:hsas_desktop/data/models/timer_model.dart';

class TimerService {
  Timer? _timer;
  List<ScheduledSwitch> _schedules = [];
  Function(String desktopId)? onSwitch;

  void start(List<ScheduledSwitch> schedules, Function(String desktopId) onSwitchCallback) {
    _schedules = schedules;
    onSwitch = onSwitchCallback;
    _timer?.cancel();
    // Check every 30 seconds for a scheduled switch
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSchedules();
    });
  }

  void updateSchedules(List<ScheduledSwitch> schedules) {
    _schedules = schedules;
  }

  void _checkSchedules() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    for (final schedule in _schedules) {
      // Check if today is a scheduled day (Monday = 1, ..., Sunday = 7)
      if (schedule.weekdays.contains(now.weekday)) {
        // Check if the time matches the current minute
        if (schedule.time.hour == currentTime.hour && schedule.time.minute == currentTime.minute) {
          onSwitch?.call(schedule.desktopId);
          // Break to avoid multiple triggers if schedules overlap in the same minute
          break;
        }
      }
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}