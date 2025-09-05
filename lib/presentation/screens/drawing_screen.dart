import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/drawing_point_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/widgets/drawing_painter.dart';
import 'package:hsas_desktop/presentation/widgets/wallpaper_widget.dart';

class DrawingScreen extends StatefulWidget {
  final DesktopModel desktop;
  const DrawingScreen({super.key, required this.desktop});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late List<DrawingPath> _currentPaths;
  Color _selectedColor = Colors.white;
  double _strokeWidth = 4.0;

  final List<Color> _colorPalette = [
    Colors.white, Colors.black, Colors.red, Colors.green, Colors.blue,
    Colors.yellow, Colors.orange, Colors.purple, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    // Create a deep copy to avoid modifying the original list until save
    _currentPaths = widget.desktop.drawingPaths.map((path) => DrawingPath.fromJson(path.toJson())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // The wallpaper and existing drawings
          Positioned.fill(
            child: WallpaperWidget(
              wallpaperPath: widget.desktop.wallpaperPath,
              drawingPaths: _currentPaths, // Show the live drawing
              isDrawingEnabled: true, // Enable drawing gestures
              onPanStart: (details) {
                setState(() {
                  _currentPaths.add(DrawingPath(
                    points: [details.localPosition],
                    color: _selectedColor,
                    strokeWidth: _strokeWidth,
                  ));
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentPaths.last.points.add(details.localPosition);
                });
              },
            ),
          ),
          // UI Controls
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        appProvider.exitDrawingModeWithoutSaving();
                        Navigator.pop(context);
                      },
                      tooltip: '取消',
                    ),
                    // Color Palette
                    Row(
                      children: _colorPalette.map((color) => _buildColorChoice(color)).toList(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: () {
                        appProvider.exitDrawingModeAndSaveChanges(widget.desktop.id, _currentPaths);
                        Navigator.pop(context);
                      },
                      tooltip: '保存并退出',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChoice(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.cyanAccent, width: 3) : null,
        ),
      ),
    );
  }
}