import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hsas_desktop/data/models/folder_portal_model.dart';
import 'package:hsas_desktop/data/services/system_service.dart';

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
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final dir = Directory(widget.portalData.path);
    if (await dir.exists()) {
      setState(() {
        _files = dir.listSync();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.portalData.path.split(Platform.pathSeparator).last,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
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
    );
  }
}