import 'dart:async';
import 'package:drift/drift.dart';
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
    required this.minutes,
    required this.task,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.linkedTodoId,
  });

  final int minutes;
  final String task;
  final String date;
  final String startTime;
  final String endTime;
  final int? linkedTodoId;
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
    this.pendingCompletion,
    this.isPaused = false,
  });

  final PomodoroPhase phase;
  final int selectedMinutes;
  final int remainingSeconds;
  final int interruptCount;
  final int? sessionId;
  final String linkedTask;
  final int? linkedTodoId;
  final PendingFocusCompletion? pendingCompletion;
  final bool isPaused;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? selectedMinutes,
    int? remainingSeconds,
    int? interruptCount,
    int? sessionId,
    String? linkedTask,
    int? linkedTodoId,
    bool clearLinkedTodo = false,
    PendingFocusCompletion? pendingCompletion,
    bool clearPending = false,
    bool? isPaused,
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
      pendingCompletion: clearPending
          ? null
          : (pendingCompletion ?? this.pendingCompletion),
      isPaused: isPaused ?? this.isPaused,
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

  void setLinkedTask(String task, {int? todoId}) {
    if (state.phase != PomodoroPhase.idle) return;
    state = state.copyWith(linkedTask: task, linkedTodoId: todoId);
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

  Future<void> _onPhaseComplete() async {
    if (_completingPhase) return;
    _completingPhase = true;
    _timer?.cancel();
    try {
      if (state.phase == PomodoroPhase.focus) {
        final pending = await _completeFocusSession();
        await _cancelFocusNotifications();
        _deadlineAt = _now().add(const Duration(minutes: 5));
        state = state.copyWith(
          phase: PomodoroPhase.breakTime,
          remainingSeconds: _remainingSeconds(),
          pendingCompletion: pending,
        );
        unawaited(_scheduleBreakEndNotification(_deadlineAt!));
        _startTicker();
      } else {
        _deadlineAt = null;
        await _cancelFocusNotifications();
        try { await WakelockPlus.disable(); } catch (_) {}
        state = const PomodoroState(
          selectedMinutes: 25,
          remainingSeconds: 25 * 60,
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
    final minutes = (actualSeconds / 60).round().clamp(1, 999);
    return PendingFocusCompletion(
      minutes: minutes,
      task: state.linkedTask,
      date: DateFormat('yyyy-MM-dd').format(_startedAt!),
      startTime: DateFormat('HH:mm').format(_startedAt!),
      endTime: DateFormat('HH:mm').format(endedAt),
      linkedTodoId: state.linkedTodoId,
    );
  }

  Future<void> recordPendingToJournal({String? note}) async {
    final pending = state.pendingCompletion;
    if (pending == null) return;
    final label = pending.task.trim().isEmpty ? '番茄专注' : pending.task.trim();
    final content = note != null && note.trim().isNotEmpty
        ? '$label（$note）'
        : label;
    final repo = JournalRepository(_ref.read(databaseProvider));
    await repo.addActualFromPomodoro(
      date: pending.date,
      startTime: pending.startTime,
      endTime: pending.endTime,
      content: content,
      linkedTodoId: pending.linkedTodoId,
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
      _onPhaseComplete();
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
