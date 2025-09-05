import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';
import 'package:hsas_desktop/data/services/system_service.dart';
import 'package:hsas_desktop/utils/app_constants.dart';

class IconWidget extends StatelessWidget {
  final IconModel iconData;
  final SystemService _systemService = SystemService();

  IconWidget({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _systemService.openPath(iconData.path, context),
      child: SizedBox(
        width: AppConstants.iconSize + 24,
        height: AppConstants.iconSize + 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder, // 可根据文件类型改变
              size: AppConstants.iconSize,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)],
            ),
            const SizedBox(height: 4),
            Text(
              iconData.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                shadows: [Shadow(blurRadius: 2.0, color: Colors.black)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}