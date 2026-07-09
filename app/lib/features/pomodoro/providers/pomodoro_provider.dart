import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../app/notification_service.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../journal/providers/journal_providers.dart';

enum PomodoroPhase { idle, focus, breakTime }

final currentTimeProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

class PendingFocusCompletion {
  const PendingFocusCompletion({
    required this.seconds,
    required this.task,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.linkedTodoId,
    this.linkedPlanId,
  });

  final int seconds;
  final String task;
  final String date;
  final String startTime;
  final String endTime;
  final int? linkedTodoId;
  final int? linkedPlanId;

  /// 兼容旧展示：向上取整到分钟（至少 0）。
  int get minutes {
    if (seconds <= 0) return 0;
    return ((seconds + 59) ~/ 60);
  }
}

class PomodoroState {
  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.selectedMinutes = 25,
    this.remainingSeconds = 0,
    this.interruptCount = 0,
    this.sessionId,
    this.linkedTask = '',
    this.linkedTodoId,
    this.linkedPlanId,
    this.pendingCompletion,
    this.isPaused = false,
    this.readyForNextRound = false,
  });

  final PomodoroPhase phase;
  final int selectedMinutes;
  final int remainingSeconds;
  final int interruptCount;
  final int? sessionId;
  final String linkedTask;
  final int? linkedTodoId;
  final int? linkedPlanId;
  final PendingFocusCompletion? pendingCompletion;
  final bool isPaused;
  final bool readyForNextRound;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? selectedMinutes,
    int? remainingSeconds,
    int? interruptCount,
    int? sessionId,
    String? linkedTask,
    int? linkedTodoId,
    bool clearLinkedTodo = false,
    int? linkedPlanId,
    bool clearLinkedPlan = false,
    PendingFocusCompletion? pendingCompletion,
    bool clearPending = false,
    bool? isPaused,
    bool? readyForNextRound,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      interruptCount: interruptCount ?? this.interruptCount,
      sessionId: sessionId ?? this.sessionId,
      linkedTask: linkedTask ?? this.linkedTask,
      linkedTodoId:
          clearLinkedTodo ? null : (linkedTodoId ?? this.linkedTodoId),
      linkedPlanId:
          clearLinkedPlan ? null : (linkedPlanId ?? this.linkedPlanId),
      pendingCompletion: clearPending
          ? null
          : (pendingCompletion ?? this.pendingCompletion),
      isPaused: isPaused ?? this.isPaused,
      readyForNextRound: readyForNextRound ?? this.readyForNextRound,
    );
  }
}

class PomodoroController extends StateNotifier<PomodoroState>
    with WidgetsBindingObserver {
  PomodoroController(this._ref) : super(const PomodoroState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Ref _ref;
  Timer? _timer;
  DateTime? _startedAt;
  DateTime? _deadlineAt;
  bool _completingPhase = false;

  DateTime _now() => _ref.read(currentTimeProvider)();

  /// [updateLinks]=true 时按传入的 todoId/planId 重绑（null 表示清空）。
  /// 仅改任务名（如输入框 onChanged）时 updateLinks=false，保留已选待办/计划关联。
  void setLinkedTask(
    String task, {
    int? todoId,
    int? planId,
    bool updateLinks = false,
  }) {
    if (state.phase != PomodoroPhase.idle) return;
    if (updateLinks) {
      state = state.copyWith(
        linkedTask: task,
        linkedTodoId: todoId,
        clearLinkedTodo: todoId == null,
        linkedPlanId: planId,
        clearLinkedPlan: planId == null,
      );
      return;
    }
    state = state.copyWith(linkedTask: task);
  }

  void selectMinutes(int minutes) {
    if (state.phase != PomodoroPhase.idle) return;
    state = state.copyWith(
      selectedMinutes: minutes,
      remainingSeconds: minutes * 60,
    );
  }

  void clearPendingCompletion() {
    state = state.copyWith(clearPending: true);
  }

  Future<void> startNextRound() async {
    if (!state.readyForNextRound) return;
    state = state.copyWith(readyForNextRound: false);
    await startFocus();
  }

  void resetNextRound() {
    if (!state.readyForNextRound) return;
    state = state.copyWith(
      readyForNextRound: false,
      selectedMinutes: 25,
      remainingSeconds: 25 * 60,
    );
  }

  void startBreak() {
    if (state.phase != PomodoroPhase.idle || state.pendingCompletion == null) {
      return;
    }
    _deadlineAt = _now().add(const Duration(minutes: 5));
    state = state.copyWith(
      phase: PomodoroPhase.breakTime,
      remainingSeconds: 5 * 60,
    );
    unawaited(_scheduleBreakEndNotification(_deadlineAt!));
    _startTicker();
  }

  void endBreakEarly() {
    if (state.phase != PomodoroPhase.breakTime) return;
    _timer?.cancel();
    _deadlineAt = null;
    unawaited(_cancelFocusNotifications());
    state = state.copyWith(
      phase: PomodoroPhase.idle,
      remainingSeconds: state.selectedMinutes * 60,
      readyForNextRound: true,
    );
  }

  void pause() {
    if (state.phase != PomodoroPhase.focus &&
        state.phase != PomodoroPhase.breakTime) {
      return;
    }
    if (state.isPaused) return;
    _timer?.cancel();
    _deadlineAt = null;
    unawaited(_cancelFocusNotifications());
    state = state.copyWith(isPaused: true);
    unawaited(WakelockPlus.disable().catchError((_) {}));
  }

  void resume() {
    if (!state.isPaused) return;
    _deadlineAt = _now().add(Duration(seconds: state.remainingSeconds));
    if (state.phase == PomodoroPhase.focus) {
      unawaited(WakelockPlus.enable().catchError((_) {}));
    }
    state = state.copyWith(isPaused: false);
    _startTicker();
  }

  Future<void> startFocus() async {
    if (state.phase != PomodoroPhase.idle) return;
    final startedAt = _now();
    final date = DateFormat('yyyy-MM-dd').format(startedAt);
    final db = _ref.read(databaseProvider);
    final sessionId = await db.insertPomodoroSession(
      PomodoroSessionsCompanion.insert(
        date: date,
        durationMinutes: state.selectedMinutes,
        startedAt: startedAt,
        linkedTodoId: Value(state.linkedTodoId),
      ),
    );
    _startedAt = startedAt;
    _deadlineAt = startedAt.add(Duration(minutes: state.selectedMinutes));
    try { await WakelockPlus.enable(); } catch (_) {}
    state = state.copyWith(
      phase: PomodoroPhase.focus,
      remainingSeconds: _remainingSeconds(),
      sessionId: sessionId,
      interruptCount: 0,
    );
    unawaited(_scheduleFocusEndNotification(_deadlineAt!, state.linkedTask));
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncRemainingWithDeadline();
    });
  }

  void _playCompletionFeedback() {
    try {
      unawaited(HapticFeedback.mediumImpact().catchError((_) {}));
    } catch (_) {}
  }

  @visibleForTesting
  Future<void> onPhaseComplete() async {
    if (_completingPhase) return;
    _completingPhase = true;
    _timer?.cancel();
    try {
      if (state.phase == PomodoroPhase.focus) {
        _playCompletionFeedback();
        final pending = await _completeFocusSession();
        await _cancelFocusNotifications();
        _deadlineAt = null;
        try { await WakelockPlus.disable(); } catch (_) {}
        state = state.copyWith(
          phase: PomodoroPhase.idle,
          pendingCompletion: pending,
        );
      } else {
        _playCompletionFeedback();
        _deadlineAt = null;
        await _cancelFocusNotifications();
        try { await WakelockPlus.disable(); } catch (_) {}
        state = state.copyWith(
          phase: PomodoroPhase.idle,
          remainingSeconds: state.selectedMinutes * 60,
          readyForNextRound: true,
        );
      }
    } finally {
      _completingPhase = false;
    }
  }

  Future<PendingFocusCompletion?> _completeFocusSession() async {
    final sessionId = state.sessionId;
    if (sessionId == null || _startedAt == null) return null;
    final endedAt = _now();
    final actualSeconds = endedAt.difference(_startedAt!).inSeconds;
    final db = _ref.read(databaseProvider);
    await db.updatePomodoroSession(
      sessionId,
      PomodoroSessionsCompanion(
        actualSeconds: Value(actualSeconds),
        completed: const Value(true),
        interruptCount: Value(state.interruptCount),
        endedAt: Value(endedAt),
      ),
    );
    return PendingFocusCompletion(
      seconds: actualSeconds.clamp(0, 24 * 3600),
      task: state.linkedTask,
      date: DateFormat('yyyy-MM-dd').format(_startedAt!),
      startTime: DateFormat('HH:mm').format(_startedAt!),
      endTime: DateFormat('HH:mm').format(endedAt),
      linkedTodoId: state.linkedTodoId,
      linkedPlanId: state.linkedPlanId,
    );
  }

  Future<void> recordPendingToJournal({String? note}) async {
    final pending = state.pendingCompletion;
    if (pending == null) return;
    final repo = JournalRepository(_ref.read(databaseProvider));

    // 若能关联到计划块：按「按计划完成」写入，今日对照直接显示「一致」，
    // 无需用户再手动点一次。专注真实时长仍保留在番茄会话记录里。
    final planned = await repo.findPlannedForFocus(
      date: pending.date,
      linkedPlanId: pending.linkedPlanId,
      linkedTodoId: pending.linkedTodoId,
    );
    if (planned != null) {
      await repo.completePlannedAsActual(
        pending.date,
        planned,
        note: note,
      );
      _ref.invalidate(journalSnapshotProvider);
      state = state.copyWith(clearPending: true);
      return;
    }

    // 有关联待办但任务名为空时，仍不要写成默认「番茄专注」
    var label = pending.task.trim();
    if (label.isEmpty && pending.linkedTodoId != null) {
      label = await repo.todoContentById(pending.linkedTodoId!) ?? '';
    }
    if (label.isEmpty) label = '番茄专注';
    final content = note != null && note.trim().isNotEmpty
        ? '$label（$note）'
        : label;
    await repo.addActualFromPomodoro(
      date: pending.date,
      startTime: pending.startTime,
      endTime: pending.endTime,
      content: content,
      linkedTodoId: pending.linkedTodoId,
      linkedPlanId: pending.linkedPlanId,
    );
    _ref.invalidate(journalSnapshotProvider);
    state = state.copyWith(clearPending: true);
  }

  Future<void> abandon() async {
    _timer?.cancel();
    _deadlineAt = null;
    await _cancelFocusNotifications();
    try { await WakelockPlus.disable(); } catch (_) {}
    final sessionId = state.sessionId;
    if (sessionId != null && _startedAt != null) {
      final db = _ref.read(databaseProvider);
      final endedAt = _now();
      await db.updatePomodoroSession(
        sessionId,
        PomodoroSessionsCompanion(
          actualSeconds: Value(endedAt.difference(_startedAt!).inSeconds),
          completed: const Value(false),
          interruptCount: Value(state.interruptCount),
          endedAt: Value(endedAt),
        ),
      );
    }
    state = PomodoroState(
      selectedMinutes: state.selectedMinutes,
      remainingSeconds: state.selectedMinutes * 60,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (this.state.isPaused) return;
    if (this.state.phase != PomodoroPhase.focus &&
        this.state.phase != PomodoroPhase.breakTime) {
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (this.state.phase == PomodoroPhase.focus) {
        this.state = this.state.copyWith(
          interruptCount: this.state.interruptCount + 1,
        );
      }
    }
    if (state == AppLifecycleState.resumed) {
      _syncRemainingWithDeadline();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(WakelockPlus.disable().catchError((_) {}));
    super.dispose();
  }

  int _remainingSeconds() {
    final deadline = _deadlineAt;
    if (deadline == null) return state.remainingSeconds;
    final remaining = deadline.difference(_now()).inSeconds;
    if (remaining < 0) return 0;
    if (remaining > 24 * 60 * 60) return 24 * 60 * 60;
    return remaining;
  }

  void _syncRemainingWithDeadline() {
    if (state.phase == PomodoroPhase.idle || state.isPaused) return;
    final remaining = _remainingSeconds();
    if (remaining <= 0) {
      onPhaseComplete();
      return;
    }
    if (remaining != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  Future<void> _scheduleFocusEndNotification(DateTime when, String task) async {
    try {
      final scheduler = _ref.read(focusNotificationSchedulerProvider);
      await scheduler.requestPermissions();
      await scheduler.scheduleFocusEnd(when, task);
    } catch (error) {
      debugPrint('Failed to schedule focus notification: $error');
    }
  }

  Future<void> _scheduleBreakEndNotification(DateTime when) async {
    try {
      await _ref
          .read(focusNotificationSchedulerProvider)
          .scheduleBreakEnd(when);
    } catch (error) {
      debugPrint('Failed to schedule break notification: $error');
    }
  }

  Future<void> _cancelFocusNotifications() async {
    try {
      await _ref
          .read(focusNotificationSchedulerProvider)
          .cancelFocusNotifications();
    } catch (error) {
      debugPrint('Failed to cancel focus notifications: $error');
    }
  }
}

final pomodoroControllerProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>((ref) {
      return PomodoroController(ref);
    });

final recentSessionsProvider =
    FutureProvider.autoDispose<List<PomodoroSession>>((ref) async {
      final db = ref.watch(databaseProvider);
      return db.recentSessions(limit: 5);
    });
