import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/presentation/widgets/drawing_painter.dart';

class WallpaperWidget extends StatelessWidget {
  final String? wallpaperPath;
  final List<DrawingPath> drawingPaths;
  final bool isDrawingEnabled;
  final Function(DragStartDetails)? onPanStart;
  final Function(DragUpdateDetails)? onPanUpdate;

  const WallpaperWidget({
    super.key,
    required this.wallpaperPath,
    required this.drawingPaths,
    this.isDrawingEnabled = false,
    this.onPanStart,
    this.onPanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // This is the transparent canvas where drawing happens.
    Widget drawingCanvas = CustomPaint(
      painter: DrawingPainter(paths: drawingPaths),
      child: Container(), // The painter needs a child to define its drawing area.
    );

    // If drawing is enabled, wrap the canvas in a gesture detector.
    if (isDrawingEnabled) {
      drawingCanvas = GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        child: drawingCanvas,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: The Wallpaper Image (at the bottom)
        if (wallpaperPath != null && File(wallpaperPath!).existsSync())
          Image.file(
            File(wallpaperPath!),
            fit: BoxFit.cover,
          )
        else
          Image.asset(
            'assets/default_wallpaper.jpg',
            fit: BoxFit.cover,
          ),

        // Layer 2: The Drawing Canvas (always on top of the image)
        drawingCanvas,
      ],
    );
  }
}