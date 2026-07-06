import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  Future<void> _showCustomDurationDialog(
    BuildContext context,
    PomodoroController controller,
  ) async {
    final minutes = await showDialog<int>(
      context: context,
      barrierColor: AppTheme.barrier,
      builder: (ctx) {
        final controller_ = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: const Text(AppCopy.focusCustomDuration),
          content: TextField(
            controller: controller_,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: AppCopy.focusCustomMinuteHint,
              helperText: AppCopy.focusCustomMinuteHelper,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppCopy.focusCancel),
            ),
            FilledButton(
              onPressed: () {
                final v = int.tryParse(controller_.text.trim());
                if (v != null && v >= 1 && v <= 180) {
                  Navigator.pop(ctx, v);
                }
              },
              child: const Text(AppCopy.focusConfirm),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;
    if (minutes != null) {
      controller.selectMinutes(minutes);
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
    final immersive = inFocus || inBreak || state.readyForNextRound;

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
            onStartBreak: () => controller.startBreak(),
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

    if (state.readyForNextRound) {
      return _buildNextRoundBody(state, controller, task);
    }

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
          if (!state.isPaused) ...[
            TextButton.icon(
              onPressed: controller.pause,
              icon: const Icon(Icons.pause_rounded, color: Colors.white54, size: 20),
              label: const Text(
                AppCopy.focusPause,
                style: TextStyle(color: Colors.white54),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ] else ...[
            TextButton.icon(
              onPressed: controller.resume,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              label: const Text(
                AppCopy.focusResume,
                style: TextStyle(color: Colors.white),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (inFocus)
            LongPressAbandonButton(onAbandoned: controller.abandon)
          else ...[
            TextButton.icon(
              onPressed: controller.endBreakEarly,
              icon: const Icon(Icons.skip_next_rounded,
                  color: Colors.white54, size: 20),
              label: const Text(
                AppCopy.focusEndBreakButton,
                style: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppCopy.focusBreakFooter,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ],
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

  Widget _buildNextRoundBody(
    PomodoroState state,
    PomodoroController controller,
    String task,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const Icon(Icons.self_improvement_rounded,
              color: Colors.white38, size: 48),
          const SizedBox(height: 20),
          const Text(
            AppCopy.focusBreakCompleteTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppCopy.focusBreakCompleteSubtitle,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          if (task.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${AppCopy.focusNextRoundContinuePrefix}$task',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '${state.selectedMinutes} ${AppCopy.focusSessionFormatMin}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const Spacer(flex: 3),
          FilledButton.icon(
            onPressed: () => controller.startNextRound(),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(AppCopy.focusNextRoundStart),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: controller.resetNextRound,
            child: Text(
              AppCopy.focusNextRoundDismiss,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            ),
          ),
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
              selectedId: state.linkedTodoId,
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
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DurationChip(
                    minutes: 5,
                    selected: state.selectedMinutes == 5,
                    onTap: () => controller.selectMinutes(5),
                  ),
                  const SizedBox(width: 10),
                  DurationChip(
                    minutes: 15,
                    selected: state.selectedMinutes == 15,
                    onTap: () => controller.selectMinutes(15),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DurationChip(
                    minutes: 25,
                    selected: state.selectedMinutes == 25,
                    onTap: () => controller.selectMinutes(25),
                  ),
                  const SizedBox(width: 10),
                  DurationChip(
                    minutes: 45,
                    selected: state.selectedMinutes == 45,
                    onTap: () => controller.selectMinutes(45),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _showCustomDurationDialog(context, controller),
                icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                label: const Text(AppCopy.focusCustomDuration),
                style: TextButton.styleFrom(foregroundColor: AppTheme.inkMuted),
              ),
            ],
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
          const SizedBox(height: 28),
          _buildRecentHistory(),
        ],
      ),
    );
  }

  Widget _buildRecentHistory() {
    final sessionsAsync = ref.watch(recentSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppCopy.focusHistoryTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 10),
        sessionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.tomato),
              ),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  AppCopy.focusHistoryEmpty,
                  style: TextStyle(fontSize: 13, color: AppTheme.inkFaint),
                ),
              );
            }
            return Column(
              children: [
                for (final s in sessions) _buildSessionRow(s),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSessionRow(dynamic session) {
    final startedAt = session.startedAt;
    final endedAt = session.endedAt;
    final started = DateFormat('HH:mm').format(startedAt);
    final ended = endedAt != null ? DateFormat('HH:mm').format(endedAt) : '—';
    final actualMin = (session.actualSeconds / 60).round();
    final label = session.completed
        ? AppCopy.focusSessionCompleteDetail(started, ended)
        : AppCopy.focusSessionAbandonedDetail(started);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            session.completed
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            size: 18,
            color: session.completed
                ? AppTheme.sleepBlue
                : AppTheme.inkFaint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: session.completed
                        ? AppTheme.ink
                        : AppTheme.inkFaint,
                  ),
                ),
                Text(
                  session.completed
                      ? AppCopy.focusSessionCompleteActual(
                          session.durationMinutes, actualMin)
                      : '${session.durationMinutes} ${AppCopy.focusSessionFormatMin}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}