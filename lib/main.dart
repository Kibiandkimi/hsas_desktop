// Flutter Windows 桌面（SUSTech 附中 高三一班）— main.dart
// 目标：
// 0. 图标可拖拽自由布局（单击打开）
// 1. 选项卡（底部中部）切换多桌面
// 2. Folder Portal：将文件夹内容直接展示在桌面（参考 Fences）
// 3. 每个桌面独立壁纸，支持在壁纸上涂鸦（画笔）
// 4. 单击打开（触摸屏一体机）
// 5. 四角功能按钮：
//    左下角 = “所有图标” 总览弹窗
//    右下角 = 最小化应用以显示原始 Windows 桌面
//    左上角 = 关机
//    右上角 = 设置
//
// 依赖（在 pubspec.yaml 中添加）：
//   window_manager: ^0.4.2
//   file_picker: ^8.0.0+1
//   path: ^1.9.0
//   path_provider: ^2.1.4
//   shared_preferences: ^2.2.3
//   watcher: ^1.1.0
//
// Windows 桌面注意：
// - 关机需要管理员权限（UAC）。这里提供调用命令示例，若无权限会失败，可改为显示引导。
// - 打开文件/程序使用 explorer 调用系统默认关联。

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1600, 900),
    center: true,
    title: 'SUSTech Affiliated HS — Class G3-1 Desktop',
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final storage = await DesktopStorage.init();
  runApp(DesktopApp(storage: storage));
}

class DesktopApp extends StatelessWidget {
  const DesktopApp({super.key, required this.storage});
  final DesktopStorage storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2D7CF3),
      ),
      home: DesktopHome(storage: storage),
    );
  }
}

// ========================= 数据模型与存储 =========================

class IconItem {
  IconItem({
    required this.id,
    required this.label,
    required this.path,
    required this.offset,
    this.isApp = false,
  });

  final String id; // 唯一 id
  final String label; // 显示名
  final String path; // 文件/文件夹/程序路径
  Offset offset; // 在桌面上的位置
  final bool isApp; // 是否是可执行程序

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'path': path,
        'dx': offset.dx,
        'dy': offset.dy,
        'isApp': isApp,
      };

  static IconItem fromJson(Map<String, dynamic> j) => IconItem(
        id: j['id'],
        label: j['label'],
        path: j['path'],
        offset: Offset((j['dx'] ?? 0).toDouble(), (j['dy'] ?? 0).toDouble()),
        isApp: j['isApp'] ?? false,
      );
}

class DesktopModel {
  DesktopModel({
    required this.id,
    required this.name,
    this.wallpaperPath,
    this.icons = const [],
    this.folderPortals = const [],
    this.strokes = const [],
  });

  final String id; // 桌面 id
  String name; // 桌面名
  String? wallpaperPath; // 壁纸路径
  List<IconItem> icons; // 自由图标
  List<FolderPortalModel> folderPortals; // Folder Portal 配置
  List<Stroke> strokes; // 涂鸦

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'wallpaperPath': wallpaperPath,
        'icons': icons.map((e) => e.toJson()).toList(),
        'folderPortals': folderPortals.map((e) => e.toJson()).toList(),
        'strokes': strokes.map((e) => e.toJson()).toList(),
      };

  static DesktopModel fromJson(Map<String, dynamic> j) => DesktopModel(
        id: j['id'],
        name: j['name'] ?? '桌面',
        wallpaperPath: j['wallpaperPath'],
        icons: (j['icons'] as List? ?? [])
            .map((e) => IconItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        folderPortals: (j['folderPortals'] as List? ?? [])
            .map((e) => FolderPortalModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        strokes: (j['strokes'] as List? ?? [])
            .map((e) => Stroke.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class FolderPortalModel {
  FolderPortalModel({
    required this.id,
    required this.dirPath,
    required this.rect,
    this.title,
  });

  final String id; // portal id
  String dirPath; // 目录路径
  Rect rect; // 在桌面上的位置和尺寸
  String? title;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dirPath': dirPath,
        'rect': {
          'l': rect.left,
          't': rect.top,
          'w': rect.width,
          'h': rect.height,
        },
        'title': title,
      };

  static FolderPortalModel fromJson(Map<String, dynamic> j) => FolderPortalModel(
        id: j['id'],
        dirPath: j['dirPath'],
        rect: Rect.fromLTWH(
          (j['rect']['l'] ?? 0).toDouble(),
          (j['rect']['t'] ?? 0).toDouble(),
          max(120.0, (j['rect']['w'] ?? 320).toDouble()),
          max(80.0, (j['rect']['h'] ?? 240).toDouble()),
        ),
        title: j['title'],
      );
}

class Stroke {
  Stroke(this.points, this.width, this.alpha);
  final List<Offset> points; // 序列点
  final double width; // 线宽
  final double alpha; // 透明度 [0,1]

  Map<String, dynamic> toJson() => {
        'points': points.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
        'width': width,
        'alpha': alpha,
      };
  static Stroke fromJson(Map<String, dynamic> j) => Stroke(
        (j['points'] as List)
            .map((e) => Offset((e['x']).toDouble(), (e['y']).toDouble()))
            .toList(),
        (j['width']).toDouble(),
        (j['alpha']).toDouble(),
      );
}

class DesktopStorage {
  DesktopStorage._(this.prefs);
  final SharedPreferences prefs;

  static const _key = 'sustech_desktops_v1';

  static Future<DesktopStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    // 首次启动提供两个默认桌面
    if (!prefs.containsKey(_key)) {
      final demo = [
        DesktopModel(id: 'd1', name: '班级活动'),
        DesktopModel(id: 'd2', name: '学习资料'),
      ];
      await prefs.setString(
          _key, jsonEncode(demo.map((e) => e.toJson()).toList()));
    }
    return DesktopStorage._(prefs);
  }

  Future<List<DesktopModel>> load() async {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => DesktopModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  Future<void> save(List<DesktopModel> desktops) async {
    await prefs.setString(
        _key, jsonEncode(desktops.map((e) => e.toJson()).toList()));
  }
}

// ========================= 主界面 =========================

class DesktopHome extends StatefulWidget {
  const DesktopHome({super.key, required this.storage});
  final DesktopStorage storage;

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> with TickerProviderStateMixin {
  late List<DesktopModel> desktops;
  late TabController tabController;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    desktops = await widget.storage.load();
    tabController = TabController(length: desktops.length, vsync: this);
    setState(() => loading = false);
  }

  Future<void> _persist() async => widget.storage.save(desktops);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (int i = 0; i < desktops.length; i++)
                DesktopCanvas(
                  model: desktops[i],
                  onChanged: () async {
                    await _persist();
                    setState(() {});
                  },
                ),
            ],
          ),

          // 底部中部的选项卡
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30),
                ),
                child: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    for (final d in desktops)
                      Tab(text: d.name.isEmpty ? '桌面' : d.name),
                  ],
                ),
              ),
            ),
          ),

          // 四角功能按钮
          // 左下角：所有图标
          Positioned(
            left: 12,
            bottom: 12,
            child: _CornerButton(
              icon: Icons.apps,
              label: '所有图标',
              onTap: () => _showAllIcons(context),
            ),
          ),
          // 右下角：最小化
          Positioned(
            right: 12,
            bottom: 12,
            child: _CornerButton(
              icon: Icons.minimize,
              label: '最小化',
              onTap: () async {
                await windowManager.minimize();
              },
            ),
          ),
          // 左上角：关机
          Positioned(
            left: 12,
            top: 12,
            child: _CornerButton(
              icon: Icons.power_settings_new,
              label: '关机',
              onTap: _confirmShutdown,
            ),
          ),
          // 右上角：设置
          Positioned(
            right: 12,
            top: 12,
            child: _CornerButton(
              icon: Icons.settings,
              label: '设置',
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      desktops: desktops,
                      onChanged: () async {
                        tabController.dispose();
                        tabController =
                            TabController(length: desktops.length, vsync: this);
                        await _persist();
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAllIcons(BuildContext context) {
    final d = desktops[tabController.index];
    final all = [
      ...d.icons,
      // 将 Folder Portal 内文件也汇总（只展示文件名，点击打开）
    ];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 800,
          height: 500,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('所有图标', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisExtent: 100,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: all.length,
                  itemBuilder: (_, i) {
                    final item = all[i];
                    return _IconTile(
                      item: item,
                      onOpen: () => _openPath(item.path),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmShutdown() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('关机确认'),
        content: const Text('确定要立即关机吗？这需要管理员权限。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('关机')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      // Windows 关机（需要权限）
      await Process.run('shutdown', ['/s', '/t', '0']);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('关机命令失败：$e')),
        );
      }
    }
  }

  Future<void> _openPath(String path) async {
    try {
      // 使用 explorer 调用默认应用打开
      await Process.run('explorer.exe', [path]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开失败：$e')),
        );
      }
    }
  }
}

class _CornerButton extends StatelessWidget {
  const _CornerButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ========================= 单个桌面画布 =========================

class DesktopCanvas extends StatefulWidget {
  const DesktopCanvas({super.key, required this.model, required this.onChanged});
  final DesktopModel model;
  final Future<void> Function() onChanged;

  @override
  State<DesktopCanvas> createState() => _DesktopCanvasState();
}

class _DesktopCanvasState extends State<DesktopCanvas> {
  // 绘图状态
  bool drawMode = false;
  double penWidth = 6.0;
  double penAlpha = 0.8;
  Stroke? currentStroke;

  @override
  Widget build(BuildContext context) {
    final d = widget.model;

    return GestureDetector(
      onPanStart: drawMode
          ? (details) {
              currentStroke = Stroke([details.localPosition], penWidth, penAlpha);
              d.strokes = [...d.strokes, currentStroke!];
              widget.onChanged();
            }
          : null,
      onPanUpdate: drawMode
          ? (details) {
              setState(() => currentStroke?.points.add(details.localPosition));
            }
          : null,
      onPanEnd: drawMode
          ? (_) {
              currentStroke = null;
              widget.onChanged();
            }
          : null,
      child: Stack(
        children: [
          // 壁纸
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                image: d.wallpaperPath == null
                    ? null
                    : DecorationImage(
                        image: FileImage(File(d.wallpaperPath!)),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),

          // 涂鸦层
          Positioned.fill(
            child: IgnorePointer(ignoring: !drawMode, child: CustomPaint(painter: _StrokePainter(d.strokes))),
          ),

          // Folder Portal 区域
          for (final fp in d.folderPortals)
            _FolderPortal(
              model: fp,
              onChanged: () async {
                await widget.onChanged();
                setState(() {});
              },
            ),

          // 自由图标
          for (final ic in d.icons)
            _MovableIcon(
              item: ic,
              onChanged: () async {
                await widget.onChanged();
                setState(() {});
              },
            ),

          // 顶部工具条（添加图标/Folder Portal/壁纸/画笔）
          Positioned(
            left: 16,
            right: 16,
            top: 60,
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _addIcon,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('添加图标'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _addFolderPortal,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('添加 Folder Portal'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _pickWallpaper,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('设置壁纸'),
                ),
                const SizedBox(width: 8),
                ToggleButtons(
                  isSelected: [drawMode],
                  onPressed: (_) => setState(() => drawMode = !drawMode),
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.brush))],
                ),
                const SizedBox(width: 8),
                if (drawMode)
                  Row(children: [
                    const Text('线宽', style: TextStyle(color: Colors.white)),
                    Slider(
                      value: penWidth,
                      min: 2,
                      max: 24,
                      onChanged: (v) => setState(() => penWidth = v),
                    ),
                    const Text('透明', style: TextStyle(color: Colors.white)),
                    Slider(
                      value: penAlpha,
                      min: 0.2,
                      max: 1.0,
                      onChanged: (v) => setState(() => penAlpha = v),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.model.strokes = [];
                        widget.onChanged();
                        setState(() {});
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('清除涂鸦'),
                    )
                  ])
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addIcon() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path!;
    final label = p.basename(path);
    widget.model.icons = [
      ...widget.model.icons,
      IconItem(
        id: 'ic_${DateTime.now().millisecondsSinceEpoch}',
        label: label,
        path: path,
        offset: const Offset(80, 140),
        isApp: path.toLowerCase().endsWith('.exe'),
      )
    ];
    await widget.onChanged();
    if (mounted) setState(() {});
  }

  Future<void> _addFolderPortal() async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    widget.model.folderPortals = [
      ...widget.model.folderPortals,
      FolderPortalModel(
        id: 'fp_${DateTime.now().millisecondsSinceEpoch}',
        dirPath: dir,
        rect: const Rect.fromLTWH(100, 240, 560, 300),
        title: p.basename(dir),
      ),
    ];
    await widget.onChanged();
    if (mounted) setState(() {});
  }

  Future<void> _pickWallpaper() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null || res.files.isEmpty) return;
    widget.model.wallpaperPath = res.files.single.path!;
    await widget.onChanged();
    if (mounted) setState(() {});
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.strokes);
  final List<Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(s.alpha)
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (int i = 0; i < s.points.length - 1; i++) {
        canvas.drawLine(s.points[i], s.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}

class _MovableIcon extends StatefulWidget {
  const _MovableIcon({required this.item, required this.onChanged});
  final IconItem item;
  final Future<void> Function() onChanged;

  @override
  State<_MovableIcon> createState() => _MovableIconState();
}

class _MovableIconState extends State<_MovableIcon> {
  late Offset pos;
  @override
  void initState() {
    super.initState();
    pos = widget.item.offset;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() => pos += d.delta);
        },
        onPanEnd: (_) async {
          widget.item.offset = pos;
          await widget.onChanged();
        },
        onTap: () => Process.run('explorer.exe', [widget.item.path]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Icon(
                  _iconForPath(widget.item.path),
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 90,
              child: Text(
                widget.item.label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  IconData _iconForPath(String path) {
    final ext = p.extension(path).toLowerCase();
    if (FileSystemEntity.isDirectorySync(path)) return Icons.folder;
    if (ext == '.exe' || ext == '.lnk') return Icons.apps;
    if (['.jpg', '.jpeg', '.png', '.bmp', '.gif', '.webp'].contains(ext)) return Icons.image;
    if (['.pdf'].contains(ext)) return Icons.picture_as_pdf;
    if (['.ppt', '.pptx'].contains(ext)) return Icons.slideshow;
    if (['.doc', '.docx'].contains(ext)) return Icons.description;
    if (['.xls', '.xlsx', '.csv'].contains(ext)) return Icons.table_chart;
    return Icons.insert_drive_file;
  }
}

class _FolderPortal extends StatefulWidget {
  const _FolderPortal({required this.model, required this.onChanged});
  final FolderPortalModel model;
  final Future<void> Function() onChanged;

  @override
  State<_FolderPortal> createState() => _FolderPortalState();
}

class _FolderPortalState extends State<_FolderPortal> {
  late Rect rect;
  late StreamSubscription<FileSystemEvent> sub;
  List<FileSystemEntity> entries = [];

  @override
  void initState() {
    super.initState();
    rect = widget.model.rect;
    _loadEntries();
    try {
      final watcher = DirectoryWatcher(widget.model.dirPath);
      sub = watcher.events.listen((_) => _loadEntries()) as StreamSubscription<FileSystemEvent>;
    } catch (_) {}
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final dir = Directory(widget.model.dirPath);
      if (!await dir.exists()) return;
      final list = await dir.list().toList();
      list.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
      setState(() => entries = list);
    } catch (e) {
      if (kDebugMode) print('FolderPortal load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() => rect = rect.shift(d.delta));
        },
        onPanEnd: (_) async {
          widget.model.rect = rect;
          await widget.onChanged();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部标题栏 + resize 拖拽角
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.model.title ?? p.basename(widget.model.dirPath),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final dir = await FilePicker.platform.getDirectoryPath();
                        if (dir == null) return;
                        widget.model.dirPath = dir;
                        await widget.onChanged();
                        _loadEntries();
                      },
                      icon: const Icon(Icons.folder_open, color: Colors.white, size: 18),
                      tooltip: '切换目录',
                    ),
                    IconButton(
                      onPressed: () async {
                        // 删除该 Portal
                        // 交给父级在 onChanged 后刷新
                        widget.model.rect = const Rect.fromLTWH(-9999, -9999, 0, 0);
                        await widget.onChanged();
                      },
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      tooltip: '移除',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) {
                    final cross = max(2, (c.maxWidth / 140).floor());
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        mainAxisExtent: 90,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (_, i) {
                        final e = entries[i];
                        final name = p.basename(e.path);
                        final isDir = FileSystemEntity.isDirectorySync(e.path);
                        return GestureDetector(
                          onTap: () => Process.run('explorer.exe', [e.path]),
                          child: Column(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Icon(
                                  isDir ? Icons.folder : Icons.insert_drive_file,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // 右下角简易 resize 手柄
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onPanUpdate: (d) {
                    setState(() => rect = Rect.fromLTWH(
                          rect.left,
                          rect.top,
                          max(240, rect.width + d.delta.dx),
                          max(120, rect.height + d.delta.dy),
                        ));
                  },
                  onPanEnd: (_) async {
                    widget.model.rect = rect;
                    await widget.onChanged();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle, color: Colors.white70, size: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ========================= 设置页 =========================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.desktops, required this.onChanged});
  final List<DesktopModel> desktops;
  final Future<void> Function() onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<DesktopModel> ds;

  @override
  void initState() {
    super.initState();
    ds = widget.desktops;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Text('桌面数量：', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  ds.add(DesktopModel(id: 'd${DateTime.now().millisecondsSinceEpoch}', name: '新桌面'));
                  await widget.onChanged();
                  setState(() {});
                },
                child: const Text('新增桌面'),
              ),
              const SizedBox(width: 8),
              if (ds.length > 1)
                OutlinedButton(
                  onPressed: () async {
                    ds.removeLast();
                    await widget.onChanged();
                    setState(() {});
                  },
                  child: const Text('删除最后一个'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          ...ds.map((d) => _desktopTile(d)).toList(),
        ],
      ),
    );
  }

  Widget _desktopTile(DesktopModel d) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('桌面名：'),
                Expanded(
                  child: TextFormField(
                    initialValue: d.name,
                    onChanged: (v) async {
                      d.name = v;
                      await widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('壁纸：'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(d.wallpaperPath ?? '未设置', overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final res = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (res == null || res.files.isEmpty) return;
                    d.wallpaperPath = res.files.single.path!;
                    await widget.onChanged();
                    setState(() {});
                  },
                  child: const Text('选择壁纸'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.item, required this.onOpen});
  final IconItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(Icons.insert_drive_file, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
