import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:hsas_desktop/presentation/widgets/corner_buttons_overlay.dart';
import 'package:hsas_desktop/presentation/widgets/desktop_page.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.desktops.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              // 主桌面内容
              IndexedStack(
                index: appProvider.activeDesktopIndex,
                children: appProvider.desktops
                    .map((desktop) => DesktopPage(desktopData: desktop))
                    .toList(),
              ),
              // 四角按钮覆盖层
              CornerButtonsOverlay(),
            ],
          );
        },
      ),
      // 底部选项卡
      bottomNavigationBar: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Container(
            height: 70,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(appProvider.desktops.length, (index) {
                final desktop = appProvider.desktops[index];
                final isActive = index == appProvider.activeDesktopIndex;
                return GestureDetector(
                  onTap: () => appProvider.changeDesktop(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      desktop.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}