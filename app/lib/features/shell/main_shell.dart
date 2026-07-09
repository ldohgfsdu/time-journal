import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/shell_navigation.dart';
import '../../app/theme.dart';
import '../journal/journal_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../pomodoro/providers/pomodoro_provider.dart';
import '../sleep/sleep_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {

  static const _tabs = [
    (icon: Icons.edit_note_rounded, activeIcon: Icons.edit_note, label: '手账'),
    (icon: Icons.timer_outlined, activeIcon: Icons.timer, label: '专注'),
    (icon: Icons.bedtime_outlined, activeIcon: Icons.bedtime, label: '睡眠'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person, label: '我的'),
  ];

  final _screens = const [
    JournalScreen(),
    PomodoroScreen(),
    SleepScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(shellTabIndexProvider);
    final pomodoro = ref.watch(pomodoroControllerProvider);
    final immersive = pomodoro.phase == PomodoroPhase.focus ||
        pomodoro.phase == PomodoroPhase.breakTime;

    return Scaffold(
      extendBody: immersive,
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: immersive ? null : _buildTabBar(index),
    );
  }

  Widget _buildTabBar(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppTheme.hairline)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = index == i;
              return Expanded(
                child: InkWell(
                  onTap: () => ref.read(shellTabIndexProvider.notifier).state = i,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? tab.activeIcon : tab.icon,
                          size: 22,
                          color: selected ? AppTheme.primary : AppTheme.mutedSoft,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w500 : FontWeight.w400,
                            color:
                                selected ? AppTheme.primary : AppTheme.mutedSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}