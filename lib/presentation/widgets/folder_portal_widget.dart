import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/folder_portal_model.dart';
import 'package:hsas_desktop/data/services/system_service.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';

class FolderPortalWidget extends StatefulWidget {
  final FolderPortalModel portalData;

  const FolderPortalWidget({super.key, required this.portalData});

  @override
  State<FolderPortalWidget> createState() => _FolderPortalWidgetState();
}

class _FolderPortalWidgetState extends State<FolderPortalWidget> {
  List<FileSystemEntity> _files = [];
  final SystemService _systemService = SystemService();

  @override
  void initState() {
    super.initState();
    _loadAndSortFiles();
  }

  @override
  void didUpdateWidget(covariant FolderPortalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload and sort if the sort type changes
    if (oldWidget.portalData.sortType != widget.portalData.sortType) {
      _loadAndSortFiles();
    }
  }

  Future<void> _loadAndSortFiles() async {
    final dir = Directory(widget.portalData.path);
    if (await dir.exists()) {
      List<FileSystemEntity> files = dir.listSync();
      // Sorting logic
      files.sort((a, b) {
        switch (widget.portalData.sortType) {
          case SortType.nameAsc:
            return a.path.toLowerCase().compareTo(b.path.toLowerCase());
          case SortType.nameDesc:
            return b.path.toLowerCase().compareTo(a.path.toLowerCase());
          case SortType.dateAsc:
            return a.statSync().modified.compareTo(b.statSync().modified);
          case SortType.dateDesc:
            return b.statSync().modified.compareTo(a.statSync().modified);
        }
      });
      setState(() {
        _files = files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: widget.portalData.size.width,
          height: widget.portalData.size.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.portalData.path.split(Platform.pathSeparator).last,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<SortType>(
                      icon: const Icon(Icons.sort, color: Colors.white),
                      onSelected: (sortType) {
                        appProvider.updatePortalSortType(widget.portalData.id, sortType);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: SortType.nameAsc, child: Text('按名称 (A-Z)')),
                        const PopupMenuItem(value: SortType.nameDesc, child: Text('按名称 (Z-A)')),
                        const PopupMenuItem(value: SortType.dateAsc, child: Text('按日期 (旧→新)')),
                        const PopupMenuItem(value: SortType.dateDesc, child: Text('按日期 (新→旧)')),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    return GestureDetector(
                      onTap: () => _systemService.openPath(file.path, context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            file is Directory ? Icons.folder : Icons.insert_drive_file,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            file.path.split(Platform.pathSeparator).last,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Resize Handle
        Positioned(
          right: -10,
          bottom: -10,
          child: GestureDetector(
            onPanUpdate: (details) {
              final newWidth = (widget.portalData.size.width + details.delta.dx).clamp(200.0, 800.0);
              final newHeight = (widget.portalData.size.height + details.delta.dy).clamp(150.0, 600.0);
              appProvider.updatePortalSize(widget.portalData.id, Size(newWidth, newHeight));
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeDownRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_full, size: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}