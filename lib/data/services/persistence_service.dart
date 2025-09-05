import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';

class PersistenceService {
  Future<File> get _localFile async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/desktop_state.json');
  }

  Future<List<DesktopModel>> loadDesktops() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => DesktopModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading state: $e");
      return [];
    }
  }

  Future<void> saveDesktops(List<DesktopModel> desktops) async {
    try {
      final file = await _localFile;
      final jsonList = desktops.map((d) => d.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      print("Error saving state: $e");
    }
  }
}