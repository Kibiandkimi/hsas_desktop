import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/services/system_service.dart';
import 'package:hsas_desktop/utils/app_constants.dart';

class CornerButtonsOverlay extends StatelessWidget {
  final SystemService _systemService = SystemService();

  CornerButtonsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 左上角: 关机
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.white),
            iconSize: AppConstants.cornerButtonSize,
            onPressed: () => _systemService.shutdown(context),
            tooltip: '关机',
          ),
        ),
        // 右上角: 设置
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            iconSize: AppConstants.cornerButtonSize,
            onPressed: () {
              // TODO: 实现设置弹窗或页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置功能待实现')),
              );
            },
            tooltip: '设置',
          ),
        ),
        // 左下角: 展示所有图标
        Positioned(
          bottom: 80, // 避开底部选项卡
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.apps, color: Colors.white),
            iconSize: AppConstants.cornerButtonSize,
            onPressed: () {
              // TODO: 实现展示所有图标弹窗
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('展示所有图标功能待实现')),
              );
            },
            tooltip: '所有应用',
          ),
        ),
        // 右下角: 最小化
        Positioned(
          bottom: 80, // 避开底部选项卡
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.minimize, color: Colors.white),
            iconSize: AppConstants.cornerButtonSize,
            onPressed: _systemService.minimizeWindow,
            tooltip: '最小化',
          ),
        ),
      ],
    );
  }
}