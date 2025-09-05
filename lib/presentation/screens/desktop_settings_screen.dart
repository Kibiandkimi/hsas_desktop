import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/screens/drawing_screen.dart';

class DesktopSettingsScreen extends StatefulWidget {
  final DesktopModel desktop;
  const DesktopSettingsScreen({super.key, required this.desktop});

  @override
  State<DesktopSettingsScreen> createState() => _DesktopSettingsScreenState();
}

class _DesktopSettingsScreenState extends State<DesktopSettingsScreen> {
  late DesktopSettingsModel _settings;

  @override
  void initState() {
    super.initState();
    _settings = DesktopSettingsModel.fromJson(widget.desktop.settings.toJson());
  }

  void _saveSettings() {
    Provider.of<AppProvider>(context, listen: false).updateDesktopSettings(widget.desktop.id, _settings);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('设置已保存')));
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.desktop.name} - 设置'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '保存设置',
          )
        ],
      ),
      backgroundColor: const Color(0xFF212121),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('外观', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ListTile(
            leading: const Icon(Icons.wallpaper, color: Colors.white),
            title: const Text('更换壁纸', style: TextStyle(color: Colors.white)),
            onTap: () => appProvider.updateDesktopWallpaper(widget.desktop.id),
          ),
          ListTile( // New "Edit Drawing" button
            leading: const Icon(Icons.draw, color: Colors.white),
            title: const Text('涂鸦编辑', style: TextStyle(color: Colors.white)),
            onTap: () {
              appProvider.enterDrawingMode(widget.desktop.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DrawingScreen(desktop: widget.desktop)),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text('交互设置', style: TextStyle(color: Colors.grey, fontSize: 16)),
          DropdownButtonFormField<ClickBehavior>(
            value: _settings.clickBehavior,
            decoration: const InputDecoration(
              labelText: '图标打开方式',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
            dropdownColor: const Color(0xFF313131),
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: ClickBehavior.singleClick, child: Text('单击打开')),
              DropdownMenuItem(value: ClickBehavior.doubleClick, child: Text('双击打开')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings.clickBehavior = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          const Text('界面元素显示', style: TextStyle(color: Colors.grey, fontSize: 16)),
          SwitchListTile(
            title: const Text('显示关机按钮', style: TextStyle(color: Colors.white)),
            value: _settings.showShutdownButton,
            onChanged: (value) => setState(() => _settings.showShutdownButton = value),
          ),
          SwitchListTile(
            title: const Text('显示设置按钮', style: TextStyle(color: Colors.white)),
            value: _settings.showSettingsButton,
            onChanged: (value) => setState(() => _settings.showSettingsButton = value),
          ),
          SwitchListTile(
            title: const Text('显示"所有应用"按钮', style: TextStyle(color: Colors.white)),
            value: _settings.showAllAppsButton,
            onChanged: (value) => setState(() => _settings.showAllAppsButton = value),
          ),
          SwitchListTile(
            title: const Text('显示最小化按钮', style: TextStyle(color: Colors.white)),
            value: _settings.showMinimizeButton,
            onChanged: (value) => setState(() => _settings.showMinimizeButton = value),
          ),
        ],
      ),
    );
  }
}