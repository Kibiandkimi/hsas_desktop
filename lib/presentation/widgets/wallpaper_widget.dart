import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/presentation/widgets/drawing_painter.dart';

class WallpaperWidget extends StatelessWidget {
  final String? wallpaperPath;
  final List<DrawingPath> drawingPaths;
  final bool isDrawingEnabled; // New property
  final Function(DragStartDetails)? onPanStart;
  final Function(DragUpdateDetails)? onPanUpdate;

  const WallpaperWidget({
    super.key,
    required this.wallpaperPath,
    required this.drawingPaths,
    this.isDrawingEnabled = false, // Default to false
    this.onPanStart,
    this.onPanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: DrawingPainter(paths: drawingPaths),
      child: Container(
        decoration: BoxDecoration(
          image: wallpaperPath != null && File(wallpaperPath!).existsSync()
              ? DecorationImage(
                  image: FileImage(File(wallpaperPath!)),
                  fit: BoxFit.cover,
                )
              : const DecorationImage(
                  image: AssetImage('assets/default_wallpaper.jpg'),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );

    if (isDrawingEnabled) {
      return GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        child: content,
      );
    }

    return content;
  }
}