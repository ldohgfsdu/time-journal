import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import 'providers/sleep_provider.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  Future<void> _pickTime({required bool bedtime, required String current}) async {
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked == null) return;
    final value = ':';
    final data = await ref.read(sleepDataProvider.future);
    await updateSleepSchedule(
      ref,
      bedtime: bedtime ? value : data.record.targetBedtime,
      wakeTime: bedtime ? data.record.targetWakeTime : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sleepAsync = ref.watch(sleepDataProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('睡眠人生')),
      body: sleepAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: ')),
        data: (data) {
          final stars = (data.totalScore ~/ 10).clamp(0, 20);
          final bedtimeText = data.record.actualBedtime == null
              ? '尚未打卡'
              : DateFormat('HH:mm').format(data.record.actualBedtime!);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF1B2A41), Color(0xFF4A6FA5)]),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('★' * stars + '☆' * (10 - stars.clamp(0, 10)), style: const TextStyle(fontSize: 20, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('连续早睡 ${data.streakDays} 天', style: const TextStyle(color: Colors.white70)),
                      Text('累计睡眠分 ${data.totalScore}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('目标就寝'),
                trailing: TextButton(onPressed: () => _pickTime(bedtime: true, current: data.record.targetBedtime), child: Text(data.record.targetBedtime)),
              ),
              ListTile(
                title: const Text('目标起床'),
                trailing: TextButton(onPressed: () => _pickTime(bedtime: false, current: data.record.targetWakeTime), child: Text(data.record.targetWakeTime)),
              ),
              ListTile(title: const Text('今日就寝打卡'), subtitle: Text(bedtimeText)),
              ListTile(title: const Text('今日睡眠分'), trailing: Text('${data.record.sleepScore} 分')),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.sleepBlue),
                onPressed: () => checkInBedtime(ref),
                child: const Text('我准备睡了'),
              ),
              const SizedBox(height: 16),
              const Text('白噪音', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['雨声', '海浪', '篝火', '风声'].map((name) {
                  return ActionChip(
                    label: Text(name),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$name 将在 v1.1 接入音频资源')),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
