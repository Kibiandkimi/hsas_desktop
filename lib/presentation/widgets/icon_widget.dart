import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';
import 'package:hsas_desktop/data/services/system_service.dart';
import 'package:hsas_desktop/utils/app_constants.dart';

class IconWidget extends StatelessWidget {
  final IconModel iconData;
  final ClickBehavior clickBehavior;
  final double iconSizeScale; // New property
  final SystemService _systemService = SystemService();

  IconWidget({
    super.key,
    required this.iconData,
    required this.clickBehavior,
    this.iconSizeScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double scaledIconSize = AppConstants.iconSize * iconSizeScale;

    return GestureDetector(
      onTap: clickBehavior == ClickBehavior.singleClick
          ? () => _systemService.openPath(iconData.path, context)
          : null,
      onDoubleTap: clickBehavior == ClickBehavior.doubleClick
          ? () => _systemService.openPath(iconData.path, context)
          : null,
      child: SizedBox(
        width: scaledIconSize + 24,
        height: scaledIconSize + 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData.type == IconType.folder ? Icons.folder : Icons.insert_drive_file,
              size: scaledIconSize,
              color: Colors.white,
              shadows: const [Shadow(blurRadius: 5.0, color: Colors.black54)],
            ),
            const SizedBox(height: 4),
            Text(
              iconData.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12 * iconSizeScale,
                shadows: const [Shadow(blurRadius: 2.0, color: Colors.black)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}