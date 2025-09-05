import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/services/system_service.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';

class AllAppsDialog extends StatelessWidget {
  const AllAppsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final allIcons = appProvider.desktops.expand((d) => d.icons).toList();
    final systemService = SystemService();

    return AlertDialog(
      title: const Text('所有应用'),
      backgroundColor: Colors.grey[900],
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: allIcons.length,
          itemBuilder: (context, index) {
            final icon = allIcons[index];
            return InkWell(
              onTap: () {
                systemService.openPath(icon.path, context);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apps, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    icon.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}