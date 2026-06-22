import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import 'providers/pomodoro_provider.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroControllerProvider);
    final controller = ref.read(pomodoroControllerProvider.notifier);
    final presets = [5, 15, 25, 45];
    final inFocus = state.phase == PomodoroPhase.focus;
    final inBreak = state.phase == PomodoroPhase.breakTime;

    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          inFocus ? '专注中' : inBreak ? '休息中' : '番茄钟',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        Text(
          _formatTime(state.remainingSeconds == 0 && state.phase == PomodoroPhase.idle
              ? state.selectedMinutes * 60
              : state.remainingSeconds),
          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w300, color: AppTheme.tomato),
        ),
        const SizedBox(height: 24),
        if (state.phase == PomodoroPhase.idle)
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: presets.map((m) {
              final selected = state.selectedMinutes == m;
              return ChoiceChip(
                label: Text('分钟'),
                selected: selected,
                onSelected: (_) => controller.selectMinutes(m),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            enabled: state.phase == PomodoroPhase.idle,
            decoration: const InputDecoration(hintText: '关联任务（可选）'),
            onChanged: controller.setLinkedTask,
          ),
        ),
        const SizedBox(height: 24),
        if (state.phase == PomodoroPhase.idle)
          FilledButton.icon(
            onPressed: controller.startFocus,
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始专注'),
          )
        else
          OutlinedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('放弃专注？'),
                  content: const Text('长按放弃后本次专注将记为未完成。'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('继续')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('放弃')),
                  ],
                ),
              );
              if (confirmed == true) await controller.abandon();
            },
            child: const Text('放弃专注'),
          ),
        if (state.interruptCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('切出次数：', style: const TextStyle(color: Colors.black54)),
          ),
      ],
    );

    if (inFocus || inBreak) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {},
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(child: Center(child: Theme(
            data: ThemeData.dark(),
            child: body,
          ))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('番茄钟')),
      body: Center(child: body),
    );
  }
}
