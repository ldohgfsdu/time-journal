import 'package:flutter/material.dart';
import '../journal/journal_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../sleep/sleep_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.menu_book_outlined, label: '手账'),
    (icon: Icons.timer_outlined, label: '专注'),
    (icon: Icons.nightlight_round, label: '睡眠'),
    (icon: Icons.person_outline, label: '我的'),
  ];

  final _screens = const [
    JournalScreen(),
    PomodoroScreen(),
    SleepScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
