import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/widgets/drawing_painter.dart';

class WallpaperWidget extends StatelessWidget {
  final String? wallpaperPath;
  final List<DrawingPath> drawingPaths;

  const WallpaperWidget({
    super.key,
    required this.wallpaperPath,
    required this.drawingPaths,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return GestureDetector(
      onPanStart: (details) {
        appProvider.addDrawingPath(DrawingPath(points: [details.localPosition]));
      },
      onPanUpdate: (details) {
        appProvider.updateCurrentDrawingPath(details.localPosition);
      },
      onPanEnd: (details) {
        // 可选：可以在这里触发保存
        appProvider.saveState();
      },
      child: CustomPaint(
        painter: DrawingPainter(paths: drawingPaths),
        child: Container(
          decoration: BoxDecoration(
            image: wallpaperPath != null && File(wallpaperPath!).existsSync()
                ? DecorationImage(
                    image: FileImage(File(wallpaperPath!)),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    // 提供一个默认壁纸
                    image: AssetImage('assets/default_wallpaper.jpg'),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }
}