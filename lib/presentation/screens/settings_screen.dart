import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/screens/desktop_settings_screen.dart';
import 'package:hsas_desktop/presentation/screens/timer_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFF212121),
      body: ListView(
        children: [
          _buildSectionTitle('全局设置'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('图标大小', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: appProvider.appSettings.iconSizeScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: (appProvider.appSettings.iconSizeScale * 100).toStringAsFixed(0) + '%',
                    onChanged: (value) {
                      appProvider.updateIconSizeScale(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildSectionTitle('定时切换'),
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.white),
            title: const Text('管理定时切换桌面', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TimerSettingsScreen()),
              );
            },
          ),
          _buildSectionTitle('桌面管理'),
          ...appProvider.desktops.map((desktop) => _buildDesktopTile(context, desktop, appProvider)),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.green),
            title: const Text('添加新桌面', style: TextStyle(color: Colors.green)),
            onTap: () => _showAddDesktopDialog(context, appProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDesktopTile(BuildContext context, DesktopModel desktop, AppProvider provider) {
    return ListTile(
      leading: const Icon(Icons.desktop_windows, color: Colors.white),
      title: Text(desktop.name, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: provider.desktops.length > 1 ? () => provider.deleteDesktop(desktop.id) : null,
            tooltip: '删除桌面',
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DesktopSettingsScreen(desktop: desktop)),
        );
      },
    );
  }

  void _showAddDesktopDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新桌面'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '桌面名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addNewDesktop(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}