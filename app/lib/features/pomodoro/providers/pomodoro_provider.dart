import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../journal/providers/journal_providers.dart';

enum PomodoroPhase { idle, focus, breakTime }

class PomodoroState {
  const PomodoroState({
    this.phase = PomodoroPhase.idle,
    this.selectedMinutes = 25,
    this.remainingSeconds = 0,
    this.interruptCount = 0,
    this.sessionId,
    this.linkedTask = '',
  });

  final PomodoroPhase phase;
  final int selectedMinutes;
  final int remainingSeconds;
  final int interruptCount;
  final int? sessionId;
  final String linkedTask;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? selectedMinutes,
    int? remainingSeconds,
    int? interruptCount,
    int? sessionId,
    String? linkedTask,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      interruptCount: interruptCount ?? this.interruptCount,
      sessionId: sessionId ?? this.sessionId,
      linkedTask: linkedTask ?? this.linkedTask,
    );
  }
}

class PomodoroController extends StateNotifier<PomodoroState> with WidgetsBindingObserver {
  PomodoroController(this._ref) : super(const PomodoroState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Ref _ref;
  Timer? _timer;
  DateTime? _startedAt;

  void setLinkedTask(String task) {
    if (state.phase != PomodoroPhase.idle) return;
    state = state.copyWith(linkedTask: task);
  }

  void selectMinutes(int minutes) {
    if (state.phase != PomodoroPhase.idle) return;
    state = state.copyWith(selectedMinutes: minutes, remainingSeconds: minutes * 60);
  }

  Future<void> startFocus() async {
    if (state.phase != PomodoroPhase.idle) return;
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final db = _ref.read(databaseProvider);
    final sessionId = await db.insertPomodoroSession(
      PomodoroSessionsCompanion.insert(
        date: date,
        durationMinutes: state.selectedMinutes,
        startedAt: DateTime.now(),
      ),
    );
    _startedAt = DateTime.now();
    await WakelockPlus.enable();
    state = state.copyWith(
      phase: PomodoroPhase.focus,
      remainingSeconds: state.selectedMinutes * 60,
      sessionId: sessionId,
      interruptCount: 0,
    );
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _onPhaseComplete();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  Future<void> _onPhaseComplete() async {
    _timer?.cancel();
    if (state.phase == PomodoroPhase.focus) {
      await _completeFocusSession();
      state = state.copyWith(phase: PomodoroPhase.breakTime, remainingSeconds: 5 * 60);
      _startTicker();
    } else {
      await WakelockPlus.disable();
      state = const PomodoroState(selectedMinutes: 25, remainingSeconds: 25 * 60);
    }
  }

  Future<void> _completeFocusSession() async {
    final sessionId = state.sessionId;
    if (sessionId == null || _startedAt == null) return;
    final endedAt = DateTime.now();
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

    final journalRepo = JournalRepository(db);
    final date = DateFormat('yyyy-MM-dd').format(_startedAt!);
    final start = DateFormat('HH:mm').format(_startedAt!);
    final end = DateFormat('HH:mm').format(endedAt);
    final label = state.linkedTask.isEmpty ? '番茄专注' : state.linkedTask;
    await journalRepo.addActualFromPomodoro(
      date: date,
      startTime: start,
      endTime: end,
      content: label,
    );
    _ref.invalidate(journalSnapshotProvider);
  }

  Future<void> abandon() async {
    _timer?.cancel();
    await WakelockPlus.disable();
    final sessionId = state.sessionId;
    if (sessionId != null && _startedAt != null) {
      final db = _ref.read(databaseProvider);
      await db.updatePomodoroSession(
        sessionId,
        PomodoroSessionsCompanion(
          actualSeconds: Value(DateTime.now().difference(_startedAt!).inSeconds),
          completed: const Value(false),
          interruptCount: Value(state.interruptCount),
          endedAt: Value(DateTime.now()),
        ),
      );
    }
    state = PomodoroState(selectedMinutes: state.selectedMinutes, remainingSeconds: state.selectedMinutes * 60);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (state.phase != PomodoroPhase.focus) return;
    if (lifecycleState == AppLifecycleState.paused || lifecycleState == AppLifecycleState.inactive) {
      state = state.copyWith(interruptCount: state.interruptCount + 1);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }
}

final pomodoroControllerProvider = StateNotifierProvider<PomodoroController, PomodoroState>((ref) {
  return PomodoroController(ref);
});
