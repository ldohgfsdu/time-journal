import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/pomodoro/providers/pomodoro_provider.dart';

final shellTabIndexProvider = StateProvider<int>((ref) => 0);

void navigateToFocusTab(WidgetRef ref, {String? task}) {
  final trimmed = task?.trim() ?? '';
  if (trimmed.isNotEmpty) {
    ref.read(pomodoroControllerProvider.notifier).setLinkedTask(trimmed);
  }
  ref.read(shellTabIndexProvider.notifier).state = 1;
}