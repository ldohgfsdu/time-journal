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
    // Claude-style floating rounded bottom nav (inside SafeArea)
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = index == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => ref.read(shellTabIndexProvider.notifier).state = i,
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.tomatoSoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? tab.activeIcon : tab.icon,
                            size: 22,
                            color: selected ? AppTheme.clay : AppTheme.inkFaint,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? AppTheme.clay : AppTheme.inkFaint,
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
      ),
    );
  }
}