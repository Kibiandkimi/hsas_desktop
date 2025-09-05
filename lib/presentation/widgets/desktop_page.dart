import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/folder_portal_model.dart';
import 'package:hsas_desktop/data/models/icon_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/widgets/folder_portal_widget.dart';
import 'package:hsas_desktop/presentation/widgets/icon_widget.dart';
import 'package:hsas_desktop/presentation/widgets/wallpaper_widget.dart';

class DesktopPage extends StatelessWidget {
  final DesktopModel desktopData;

  const DesktopPage({super.key, required this.desktopData});

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final position = details.localPosition;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx + 1, position.dy + 1),
      items: const [
        PopupMenuItem<String>(value: 'add_icon', child: Text('添加图标/文件夹...')),
        PopupMenuItem<String>(value: 'add_portal', child: Text('添加文件夹传送门...')),
        PopupMenuDivider(),
        PopupMenuItem<String>(value: 'clear_drawings', child: Text('清除涂鸦')),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'add_icon':
          appProvider.addIconToCurrentDesktop(position);
          break;
        case 'add_portal':
          appProvider.addPortalToCurrentDesktop(position);
          break;
        case 'clear_drawings':
          appProvider.clearDrawings();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final iconSizeScale = appProvider.appSettings.iconSizeScale;

    return GestureDetector(
      onSecondaryTapDown: (details) => _showContextMenu(context, details),
      child: DragTarget<Object>( // Accept any object
        onAcceptWithDetails: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localOffset = renderBox.globalToLocal(details.offset);

          if (details.data is IconModel) {
            appProvider.updateIconPosition((details.data as IconModel).id, localOffset);
          } else if (details.data is FolderPortalModel) {
            appProvider.updatePortalPosition((details.data as FolderPortalModel).id, localOffset);
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              Positioned.fill(
                child: WallpaperWidget(
                  wallpaperPath: desktopData.wallpaperPath,
                  drawingPaths: desktopData.drawingPaths,
                ),
              ),
              ...desktopData.icons.map((iconData) {
                return Positioned(
                  left: iconData.position.dx,
                  top: iconData.position.dy,
                  child: Draggable<IconModel>(
                    data: iconData,
                    feedback: IconWidget(iconData: iconData, clickBehavior: desktopData.settings.clickBehavior, iconSizeScale: iconSizeScale),
                    childWhenDragging: Opacity(opacity: 0.4, child: IconWidget(iconData: iconData, clickBehavior: desktopData.settings.clickBehavior, iconSizeScale: iconSizeScale)),
                    child: IconWidget(iconData: iconData, clickBehavior: desktopData.settings.clickBehavior, iconSizeScale: iconSizeScale),
                  ),
                );
              }).toList(),
              ...desktopData.portals.map((portalData) {
                return Positioned(
                  left: portalData.position.dx,
                  top: portalData.position.dy,
                  child: Draggable<FolderPortalModel>(
                    data: portalData,
                    feedback: Material(color: Colors.transparent, child: FolderPortalWidget(portalData: portalData)),
                    childWhenDragging: Opacity(opacity: 0.4, child: FolderPortalWidget(portalData: portalData)),
                    child: FolderPortalWidget(portalData: portalData),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}