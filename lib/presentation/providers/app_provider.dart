import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';
import 'package:hsas_desktop/data/services/persistence_service.dart';
import 'package:uuid/uuid.dart';

class AppProvider extends ChangeNotifier {
  final PersistenceService _persistenceService = PersistenceService();
  final Uuid _uuid = const Uuid();

  List<DesktopModel> _desktops = [];
  int _activeDesktopIndex = 0;

  List<DesktopModel> get desktops => _desktops;
  int get activeDesktopIndex => _activeDesktopIndex;
  DesktopModel get activeDesktop => _desktops[_activeDesktopIndex];

  AppProvider() {
    // 初始化时加载状态或创建默认桌面
    loadState();
  }

  Future<void> loadState() async {
    _desktops = await _persistenceService.loadDesktops();
    if (_desktops.isEmpty) {
      _createDefaultDesktops();
    }
    notifyListeners();
  }

  Future<void> saveState() async {
    await _persistenceService.saveDesktops(_desktops);
  }

  void _createDefaultDesktops() {
    _desktops = [
      DesktopModel(id: _uuid.v4(), name: '学习'),
      DesktopModel(id: _uuid.v4(), name: '娱乐'),
      DesktopModel(id: _uuid.v4(), name: '项目'),
    ];
  }

  void changeDesktop(int index) {
    if (index >= 0 && index < _desktops.length) {
      _activeDesktopIndex = index;
      notifyListeners();
    }
  }

  void updateIconPosition(String iconId, Offset newPosition) {
    try {
      final icon = activeDesktop.icons.firstWhere((i) => i.id == iconId);
      icon.position = newPosition;
      notifyListeners();
      saveState();
    } catch (e) {
      print("Icon not found: $iconId");
    }
  }

  void addDrawingPath(DrawingPath path) {
    activeDesktop.drawingPaths.add(path);
    notifyListeners();
    saveState();
  }

  void updateCurrentDrawingPath(Offset point) {
    if (activeDesktop.drawingPaths.isNotEmpty) {
      activeDesktop.drawingPaths.last.points.add(point);
      notifyListeners();
    }
  }

  void clearDrawings() {
    activeDesktop.drawingPaths.clear();
    notifyListeners();
    saveState();
  }
}