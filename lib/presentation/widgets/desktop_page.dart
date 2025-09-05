import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/widgets/folder_portal_widget.dart';
import 'package:hsas_desktop/presentation/widgets/icon_widget.dart';
import 'package:hsas_desktop/presentation/widgets/wallpaper_widget.dart';

class DesktopPage extends StatelessWidget {
  final DesktopModel desktopData;

  const DesktopPage({super.key, required this.desktopData});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return DragTarget<IconModel>(
      onAcceptWithDetails: (details) {
        // 将全局坐标转换为相对于Stack的局部坐标
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localOffset = renderBox.globalToLocal(details.offset);
        appProvider.updateIconPosition(details.data.id, localOffset);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            // 1. 壁纸和绘画层
            Positioned.fill(
              child: WallpaperWidget(
                wallpaperPath: desktopData.wallpaperPath,
                drawingPaths: desktopData.drawingPaths,
              ),
            ),

            // 2. 图标和Portal层
            ...desktopData.icons.map((iconData) {
              return Positioned(
                left: iconData.position.dx,
                top: iconData.position.dy,
                child: Draggable<IconModel>(
                  data: iconData,
                  feedback: IconWidget(iconData: iconData),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: IconWidget(iconData: iconData),
                  ),
                  child: IconWidget(iconData: iconData),
                ),
              );
            }).toList(),

            ...desktopData.portals.map((portalData) {
              return Positioned(
                left: portalData.position.dx,
                top: portalData.position.dy,
                child: FolderPortalWidget(portalData: portalData),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}