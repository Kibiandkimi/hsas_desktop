import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hsas_desktop/data/models/app_settings_model.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/timer_model.dart';

class PersistenceService {
  Future<File> _getFile(String fileName) async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$fileName');
  }

  // --- Desktop State ---
  Future<List<DesktopModel>> loadDesktops() async {
    try {
      final file = await _getFile('desktop_state.json');
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => DesktopModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading desktop state: $e");
      return [];
    }
  }

  Future<void> saveDesktops(List<DesktopModel> desktops) async {
    try {
      final file = await _getFile('desktop_state.json');
      final jsonList = desktops.map((d) => d.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print("Error saving desktop state: $e");
    }
  }

  // --- Timer State ---
  Future<List<ScheduledSwitch>> loadSchedules() async {
    try {
      final file = await _getFile('timer_state.json');
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => ScheduledSwitch.fromJson(json)).toList();
    } catch (e) {
      print("Error loading timer state: $e");
      return [];
    }
  }

  Future<void> saveSchedules(List<ScheduledSwitch> schedules) async {
    try {
      final file = await _getFile('timer_state.json');
      final jsonList = schedules.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print("Error saving timer state: $e");
    }
  }

  // --- App Settings State (NEW) ---
  Future<AppSettingsModel> loadAppSettings() async {
    try {
      final file = await _getFile('app_settings.json');
      if (!await file.exists()) return AppSettingsModel();
      final contents = await file.readAsString();
      return AppSettingsModel.fromJson(jsonDecode(contents));
    } catch (e) {
      print("Error loading app settings: $e");
      return AppSettingsModel();
    }
  }

  Future<void> saveAppSettings(AppSettingsModel settings) async {
    try {
      final file = await _getFile('app_settings.json');
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (e) {
      print("Error saving app settings: $e");
    }
  }
}