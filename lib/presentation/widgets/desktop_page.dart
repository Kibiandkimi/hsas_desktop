import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
        PopupMenuItem<String>(value: 'add_file', child: Text('添加文件...')),
        PopupMenuItem<String>(value: 'add_folder', child: Text('添加文件夹...')),
        PopupMenuItem<String>(value: 'add_portal', child: Text('添加文件夹传送门...')),
        PopupMenuDivider(),
        PopupMenuItem<String>(value: 'clear_drawings', child: Text('清除涂鸦')),
      ],
    ).then((value) async {
      if (value == null) return;
      switch (value) {
        case 'add_file':
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null && result.files.single.path != null) {
            appProvider.addIconToCurrentDesktop(
              result.files.single.path!,
              result.files.single.name,
              IconType.file,
              position,
            );
          }
          break;
        case 'add_folder':
          String? directoryPath = await FilePicker.platform.getDirectoryPath();
          if (directoryPath != null) {
            appProvider.addIconToCurrentDesktop(
              directoryPath,
              directoryPath.split(Platform.pathSeparator).last,
              IconType.folder,
              position,
            );
          }
          break;
        case 'add_portal':
          appProvider.addPortalToCurrentDesktop(position);
          break;
        case 'clear_drawings':
          // This action is now implicitly handled by the drawing screen,
          // but we can leave it here to clear all drawings at once.
          final desktop = appProvider.activeDesktop;
          appProvider.exitDrawingModeAndSaveChanges(desktop.id, []);
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
      child: DragTarget<Object>(
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
                  isDrawingEnabled: false, // Drawing is disabled in normal view
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