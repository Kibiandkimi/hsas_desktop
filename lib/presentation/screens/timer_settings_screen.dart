import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hsas_desktop/data/models/desktop_model.dart';
import 'package:hsas_desktop/data/models/timer_model.dart';
import 'package:hsas_desktop/presentation/providers/app_provider.dart';
import 'package:uuid/uuid.dart';

class TimerSettingsScreen extends StatelessWidget {
  const TimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('定时切换设置'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFF212121),
      body: ListView.builder(
        itemCount: appProvider.schedules.length,
        itemBuilder: (context, index) {
          final schedule = appProvider.schedules[index];

          // --- CORRECTED LOGIC HERE ---
          String desktopName = '未知桌面 (可能已被删除)';
          try {
            desktopName = appProvider.desktops.firstWhere((d) => d.id == schedule.desktopId).name;
          } catch (e) {
            // Keep the default name if not found
          }
          // --- END OF CORRECTION ---

          return ListTile(
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: Text('切换到 "$desktopName" 在 ${schedule.time.format(context)}', style: const TextStyle(color: Colors.white)),
            subtitle: Text(_getWeekdaysString(schedule.weekdays), style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => appProvider.deleteSchedule(schedule.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context, appProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getWeekdaysString(List<int> weekdays) {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    if (weekdays.length == 7) return '每天';
    if (weekdays.toSet().containsAll([1, 2, 3, 4, 5]) && weekdays.length == 5) return '工作日';
    weekdays.sort(); // Sort for consistent output
    return weekdays.map((d) => '周${days[d - 1]}').join(', ');
  }

  void _showAddScheduleDialog(BuildContext context, AppProvider provider) {
    if (provider.desktops.isEmpty) return; // Don't show dialog if no desktops exist

    String? selectedDesktopId = provider.desktops.first.id;
    TimeOfDay? selectedTime;
    final List<int> selectedWeekdays = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加定时任务'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDesktopId,
                      items: provider.desktops.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                      onChanged: (value) => setState(() => selectedDesktopId = value),
                      decoration: const InputDecoration(labelText: '目标桌面'),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(selectedTime == null ? '选择时间' : selectedTime!.format(context)),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final isSelected = selectedWeekdays.contains(day);
                        return FilterChip(
                          label: Text('周${const ['一', '二', '三', '四', '五', '六', '日'][index]}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedWeekdays.add(day);
                              } else {
                                selectedWeekdays.remove(day);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                TextButton(
                  onPressed: () {
                    if (selectedDesktopId != null && selectedTime != null && selectedWeekdays.isNotEmpty) {
                      provider.addSchedule(ScheduledSwitch(
                        id: const Uuid().v4(),
                        desktopId: selectedDesktopId!,
                        time: selectedTime!,
                        weekdays: selectedWeekdays,
                      ));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写所有字段')),
                      );
                    }
                  },
                  child: const Text('添加'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}