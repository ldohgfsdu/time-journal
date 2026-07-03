import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/copy.dart';
import '../../app/gentle_feedback.dart';
import '../../app/shell_navigation.dart';
import '../../app/theme.dart';
import '../journal/providers/journal_providers.dart';
import '../journal/widgets/todo_pick_chips.dart';
import 'providers/pomodoro_provider.dart';
import 'widgets/breathing_timer_text.dart';
import 'widgets/duration_chip.dart';
import 'widgets/long_press_abandon_button.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  final _taskController = TextEditingController();
  bool _immersive = false;

  static const _timerStyle = TextStyle(
    fontSize: 80,
    fontWeight: FontWeight.w300,
    color: AppTheme.tomato,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTaskFromProvider());
  }

  @override
  void dispose() {
    _restoreSystemUi();
    _taskController.dispose();
    super.dispose();
  }

  void _enterImmersive() {
    if (_immersive) return;
    _immersive = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  void _restoreSystemUi() {
    if (!_immersive) return;
    _immersive = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _syncTaskFromProvider() {
    final task = ref.read(pomodoroControllerProvider).linkedTask;
    if (task.isNotEmpty && _taskController.text != task) {
      _taskController.text = task;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(shellTabIndexProvider, (prev, next) {
      if (next == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncTaskFromProvider());
      }
    });
    final state = ref.watch(pomodoroControllerProvider);
    final controller = ref.read(pomodoroControllerProvider.notifier);
    final presets = [5, 15, 25, 45];
    final inFocus = state.phase == PomodoroPhase.focus;
    final inBreak = state.phase == PomodoroPhase.breakTime;
    final immersive = inFocus || inBreak;

    ref.listen<PomodoroState>(pomodoroControllerProvider, (prev, next) {
      final pending = next.pendingCompletion;
      if (pending != null && prev?.pendingCompletion == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await GentleFeedback.focusCompletedSheet(
            context,
            pending: pending,
            onRecord: ({String? note}) =>
                controller.recordPendingToJournal(note: note),
            onDismiss: controller.clearPendingCompletion,
          );
        });
      }
    });

    if (immersive && !_immersive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _enterImmersive());
    } else if (!immersive && _immersive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSystemUi());
    }

    if (immersive) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: SafeArea(
            bottom: false,
            child: _buildImmersiveBody(state, controller, inFocus),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.focusTitle)),
      body: _buildIdleBody(state, controller, presets),
    );
  }

  Widget _buildImmersiveBody(
    PomodoroState state,
    PomodoroController controller,
    bool inFocus,
  ) {
    final seconds = state.remainingSeconds;
    final task = state.linkedTask.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            inFocus ? AppCopy.focusImmersed : AppCopy.focusBreak,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: inFocus ? 4 : 0.5,
            ),
          ),
          if (inFocus && task.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              task,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
          const SizedBox(height: 24),
          BreathingTimerText(
            text: _formatTime(seconds),
            style: _timerStyle,
          ),
          const Spacer(flex: 3),
          if (inFocus)
            LongPressAbandonButton(onAbandoned: controller.abandon)
          else
            Text(
              AppCopy.focusBreakFooter,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
            ),
          if (state.interruptCount > 0) ...[
            const SizedBox(height: 16),
            Text(
              AppCopy.focusInterrupt(state.interruptCount),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildIdleBody(
    PomodoroState state,
    PomodoroController controller,
    List<int> presets,
  ) {
    final displaySeconds = state.remainingSeconds == 0
        ? state.selectedMinutes * 60
        : state.remainingSeconds;
    final todosAsync = ref.watch(todayTodosProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            AppCopy.focusTaskPrompt,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.rule),
            ),
            child: TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                hintText: AppCopy.focusTaskHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.tomato),
                ),
              ),
              onChanged: controller.setLinkedTask,
            ),
          ),
          todosAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (todos) => TodoPickChips(
              label: AppCopy.focusPickFromTodo,
              todos: todos,
              onPick: (todo) {
                GentleFeedback.lightTap();
                _taskController.text = todo.content;
                controller.setLinkedTask(todo.content, todoId: todo.id);
              },
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: BreathingTimerText(
              text: _formatTime(displaySeconds),
              style: _timerStyle.copyWith(fontSize: 72),
              enabled: false,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: presets.map((m) {
              return DurationChip(
                minutes: m,
                selected: state.selectedMinutes == m,
                onTap: () => controller.selectMinutes(m),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {
              GentleFeedback.focusStarted();
              controller.startFocus();
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(AppCopy.focusStartWith(state.selectedMinutes)),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}