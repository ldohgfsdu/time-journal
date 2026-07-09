import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/app/notification_service.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/local/database_provider.dart';
import 'package:time_journal/data/models/comparison_slot.dart';
import 'package:time_journal/data/repositories/journal_repository.dart';
import 'package:time_journal/features/pomodoro/providers/pomodoro_provider.dart';

class _StubNotificationScheduler implements FocusNotificationScheduler {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> requestPermissions() async {}
  @override
  Future<void> scheduleFocusEnd(DateTime when, String task) async {}
  @override
  Future<void> scheduleBreakEnd(DateTime when) async {}
  @override
  Future<void> cancelFocusNotifications() async {}
}

ProviderContainer _createContainer(AppDatabase db, DateTime fakeNow) {
  return ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    currentTimeProvider.overrideWithValue(() => fakeNow),
    focusNotificationSchedulerProvider
        .overrideWithValue(_StubNotificationScheduler()),
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;
  late PomodoroController controller;
  // Fixed clock starts at 09:00
  DateTime fakeNow = DateTime(2026, 7, 4, 9, 0);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = _createContainer(db, fakeNow);
    controller = container.read(pomodoroControllerProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  // ── pause / resume ───────────────────────────────────────────

  group('pause and resume', () {
    test('pause during focus sets isPaused', () async {
      controller.selectMinutes(25);
      await controller.startFocus();

      expect(controller.state.phase, PomodoroPhase.focus);
      expect(controller.state.isPaused, false);

      controller.pause();
      expect(controller.state.isPaused, true);
    });

    test('pause in idle is a no-op', () {
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.isPaused, false);

      controller.pause();
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.isPaused, false);
    });

    test('resume restores isPaused to false', () async {
      controller.selectMinutes(25);
      await controller.startFocus();
      controller.pause();
      expect(controller.state.isPaused, true);

      controller.resume();
      expect(controller.state.isPaused, false);
    });

    test('resume in non-paused state is a no-op', () async {
      controller.selectMinutes(25);
      await controller.startFocus();
      expect(controller.state.isPaused, false);

      // resume() without prior pause should not crash or change state
      controller.resume();
      expect(controller.state.isPaused, false);
      expect(controller.state.phase, PomodoroPhase.focus);
    });

    test('pause preserves remainingSeconds', () async {
      controller.selectMinutes(25);
      await controller.startFocus();
      final before = controller.state.remainingSeconds;
      expect(before, 25 * 60);

      controller.pause();
      // remainingSeconds unchanged after pause
      expect(controller.state.remainingSeconds, before);
    });

    test('resume preserves sessionId without creating new session',
        () async {
      controller.selectMinutes(25);
      await controller.startFocus();
      final sessionId = controller.state.sessionId;
      expect(sessionId, isNotNull);

      controller.pause();
      controller.resume();

      // sessionId unchanged
      expect(controller.state.sessionId, sessionId);
      // only one session in DB
      final sessions = await db.select(db.pomodoroSessions).get();
      expect(sessions.length, 1);
    });

    test('abandon works while paused', () async {
      controller.selectMinutes(25);
      await controller.startFocus();
      controller.pause();
      expect(controller.state.isPaused, true);

      await controller.abandon();

      // State reset to idle, isPaused cleared
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.isPaused, false);
      expect(controller.state.sessionId, isNull);
    });

    test(
        'pause does not increase interrupt count via lifecycle',
        () async {
      controller.selectMinutes(25);
      await controller.startFocus();

      controller.pause();

      // Simulate app going to background while paused
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      // Interrupt count should not increase because isPaused=true
      expect(controller.state.interruptCount, 0);
    });
  });

  // ── next round ──────────────────────────────────────────────

  group('next round', () {
    test('focus complete does not force break', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending

      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.pendingCompletion, isNotNull);
      expect(controller.state.readyForNextRound, false);
    });

    test('user can start break after focus complete', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending

      expect(controller.state.pendingCompletion, isNotNull);
      controller.startBreak();

      expect(controller.state.phase, PomodoroPhase.breakTime);
      expect(controller.state.remainingSeconds, 5 * 60);
    });

    test('startBreak is no-op without pendingCompletion', () async {
      controller.selectMinutes(25);
      controller.startBreak(); // no pending → no-op
      expect(controller.state.phase, PomodoroPhase.idle);
    });

    test('readyForNextRound is true after break ends naturally', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak(); // idle → break
      await controller.onPhaseComplete(); // break → ready

      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, true);
    });

    test('endBreakEarly goes to readyForNextRound', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak(); // idle → break

      expect(controller.state.phase, PomodoroPhase.breakTime);
      controller.endBreakEarly();

      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, true);
    });

    test('endBreakEarly is no-op when not in break', () async {
      controller.selectMinutes(25);
      controller.endBreakEarly();
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, false);
    });

    test('startNextRound begins a new focus session', () async {
      controller.setLinkedTask('背单词');
      controller.selectMinutes(25);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak();
      await controller.onPhaseComplete(); // break → ready

      expect(controller.state.readyForNextRound, true);
      expect(controller.state.linkedTask, '背单词');

      await controller.startNextRound();

      expect(controller.state.phase, PomodoroPhase.focus);
      expect(controller.state.readyForNextRound, false);
      expect(controller.state.sessionId, isNotNull);
    });

    test('startNextRound creates one new session, not reusing old',
        () async {
      controller.selectMinutes(25);
      await controller.startFocus();
      final firstSessionId = controller.state.sessionId;
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak();
      await controller.onPhaseComplete(); // break → ready

      await controller.startNextRound();
      final secondSessionId = controller.state.sessionId;

      expect(secondSessionId, isNot(firstSessionId));
      final sessions = await db.select(db.pomodoroSessions).get();
      expect(sessions.length, 2);
    });

    test('abandon clears readyForNextRound', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak();
      await controller.onPhaseComplete(); // break → ready

      expect(controller.state.readyForNextRound, true);

      await controller.abandon();
      expect(controller.state.readyForNextRound, false);
      expect(controller.state.phase, PomodoroPhase.idle);
    });

    test('pause is no-op in readyForNextRound state', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak();
      await controller.onPhaseComplete(); // break → ready

      controller.pause();
      expect(controller.state.readyForNextRound, true);
      expect(controller.state.isPaused, false);
    });

    test('completion feedback does not break state transitions', () async {
      controller.selectMinutes(5);
      await controller.startFocus();

      // focus → idle + pendingCompletion
      await controller.onPhaseComplete();
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.pendingCompletion, isNotNull);

      // start break → breakTime
      controller.startBreak();
      expect(controller.state.phase, PomodoroPhase.breakTime);

      // break → ready
      await controller.onPhaseComplete();
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, true);
    });
  });

  // ── break flow ─────────────────────────────────────────────

  group('break flow', () {
    test('skip break dismisses pending and goes to idle', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending

      expect(controller.state.pendingCompletion, isNotNull);
      controller.clearPendingCompletion();
      expect(controller.state.pendingCompletion, isNull);
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, false);
    });

    test('pause and resume work during break', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → idle + pending
      controller.startBreak();

      expect(controller.state.phase, PomodoroPhase.breakTime);
      controller.pause();
      expect(controller.state.isPaused, true);

      controller.resume();
      expect(controller.state.isPaused, false);
    });
  });

  group('recentSessions', () {
    test('returns empty when no sessions exist', () async {
      final sessions = await db.recentSessions();
      expect(sessions, isEmpty);
    });

    test('returns sessions ordered by startedAt desc', () async {
      final id1 = await db.insertPomodoroSession(
        PomodoroSessionsCompanion.insert(
          date: '2026-07-01',
          durationMinutes: 25,
          startedAt: DateTime(2026, 7, 1, 9, 0),
        ),
      );
      final id2 = await db.insertPomodoroSession(
        PomodoroSessionsCompanion.insert(
          date: '2026-07-02',
          durationMinutes: 45,
          startedAt: DateTime(2026, 7, 2, 14, 0),
        ),
      );
      await db.updatePomodoroSession(
        id1,
        const PomodoroSessionsCompanion(
          completed: Value(true),
          actualSeconds: Value(1500),
          endedAt: Value(null),
        ),
      );
      await db.updatePomodoroSession(
        id2,
        const PomodoroSessionsCompanion(
          completed: Value(false),
          actualSeconds: Value(900),
          endedAt: Value(null),
        ),
      );

      final sessions = await db.recentSessions(limit: 5);
      // Most recent first
      expect(sessions.first.startedAt, DateTime(2026, 7, 2, 14, 0));
      expect(sessions.first.completed, false);
      expect(sessions.last.completed, true);
    });

    test('respects limit', () async {
      for (var i = 0; i < 7; i++) {
        await db.insertPomodoroSession(
          PomodoroSessionsCompanion.insert(
            date: '2026-07-0${i + 1}',
            durationMinutes: 25,
            startedAt: DateTime(2026, 7, i + 1, 9, 0),
          ),
        );
      }
      final sessions = await db.recentSessions(limit: 3);
      expect(sessions.length, 3);
    });
  });

  // ── linked task / plan flow (for PR #8) ───────────────────────

  group('linked task and plan', () {
    test('journal todo focus action retains task + linkedTodoId in pending, records non-default content', () async {
      // Simulate creating todo and planned (as from journal schedule)
      final todo = await db.into(db.todoItems).insertReturning(
        TodoItemsCompanion.insert(
          journalDate: '2026-07-04',
          content: const Value('睡觉'),
          sortOrder: const Value(0),
        ),
      );
      final planned = await db.into(db.timeBlocks).insertReturning(
        TimeBlocksCompanion.insert(
          journalDate: '2026-07-04',
          startTime: '01:45',
          endTime: '08:30',
          content: const Value('睡觉'),
          source: 'planned',
          linkedTodoId: Value(todo.id),
          sortOrder: const Value(0),
        ),
      );

      // Simulate from journal todo focus action: set with task + todoId (no planId)
      controller.setLinkedTask('睡觉', todoId: todo.id, updateLinks: true);

      controller.selectMinutes(1);
      await controller.startFocus();

      // Force complete (simulates timer end)
      await controller.onPhaseComplete();

      final pending = controller.state.pendingCompletion;
      expect(pending, isNotNull);
      expect(pending!.task, '睡觉');
      expect(pending.linkedTodoId, todo.id);
      expect(pending.linkedPlanId, isNull); // not passed directly

      // Record
      await controller.recordPendingToJournal();

      // Verify actual
      final repo = JournalRepository(db);
      final snapshot = await repo.load('2026-07-04');
      final actuals = snapshot.actualBlocks.where((a) => a.linkedTodoId == todo.id).toList();
      expect(actuals, hasLength(1));
      expect(actuals.first.content, '睡觉'); // not default "番茄专注"
      expect(actuals.first.linkedPlanId, planned.id); // backfilled
    });

    test('pomodoro actual with linkedTodoId links back to planned with same linkedTodoId', () async {
      final todo = await db.into(db.todoItems).insertReturning(
        TodoItemsCompanion.insert(
          journalDate: '2026-07-04',
          content: const Value('健身'),
          sortOrder: const Value(0),
        ),
      );
      final planned = await db.into(db.timeBlocks).insertReturning(
        TimeBlocksCompanion.insert(
          journalDate: '2026-07-04',
          startTime: '21:20',
          endTime: '22:20',
          content: const Value('健身'),
          source: 'planned',
          linkedTodoId: Value(todo.id),
          sortOrder: const Value(0),
        ),
      );

      controller.setLinkedTask('健身', todoId: todo.id, updateLinks: true);
      controller.selectMinutes(1);
      await controller.startFocus();
      await controller.onPhaseComplete();
      await controller.recordPendingToJournal();

      final repo = JournalRepository(db);
      final snapshot = await repo.load('2026-07-04');
      final slot = snapshot.comparisonSlots.firstWhere((s) => s.planned?.id == planned.id);
      expect(slot.actual, isNotNull);
      expect(slot.actual!.content, '健身');
      expect(slot.actual!.startTime, planned.startTime);
      expect(slot.actual!.endTime, planned.endTime);
      expect(slot.orphanActual, isFalse);
      expect(slot.status, SlotStatus.match);
    });

    test('manual planned block without linkedTodoId links via planId (today comparison focus)', () async {
      final planned = await db.into(db.timeBlocks).insertReturning(
        TimeBlocksCompanion.insert(
          journalDate: '2026-07-04',
          startTime: '01:45',
          endTime: '08:30',
          content: const Value('睡觉'),
          source: 'planned',
          sortOrder: const Value(0),
        ),
      );

      // Simulate navigateToFocusTab from today comparison planned card menu
      controller.setLinkedTask(
        planned.content,
        planId: planned.id,
        todoId: planned.linkedTodoId,
        updateLinks: true,
      );
      controller.selectMinutes(1);
      await controller.startFocus();
      await controller.onPhaseComplete();

      final pending = controller.state.pendingCompletion;
      expect(pending, isNotNull);
      expect(pending!.task, '睡觉');
      expect(pending.linkedPlanId, planned.id);
      expect(pending.linkedTodoId, isNull);

      await controller.recordPendingToJournal();

      final repo = JournalRepository(db);
      final snapshot = await repo.load('2026-07-04');
      final actuals = snapshot.actualBlocks;
      expect(actuals, hasLength(1));
      expect(actuals.first.content, '睡觉');
      expect(actuals.first.linkedPlanId, planned.id);
      expect(actuals.first.linkedTodoId, isNull);

      final slot = snapshot.comparisonSlots.firstWhere((s) => s.planned?.id == planned.id);
      expect(slot.actual, isNotNull);
      expect(slot.actual!.content, '睡觉');
      expect(slot.actual!.startTime, planned.startTime);
      expect(slot.actual!.endTime, planned.endTime);
      expect(slot.orphanActual, isFalse);
      expect(slot.status, SlotStatus.match);
      expect(snapshot.comparisonSlots.where((s) => s.orphanActual), isEmpty);
    });

    test('no task selected still generates orphan "番茄专注"', () async {
      controller.selectMinutes(1);
      await controller.startFocus();
      await controller.onPhaseComplete();
      await controller.recordPendingToJournal();

      final repo = JournalRepository(db);
      final snapshot = await repo.load('2026-07-04');
      final actuals = snapshot.actualBlocks;
      expect(actuals, hasLength(1));
      expect(actuals.first.content, '番茄专注');
      expect(actuals.first.linkedTodoId, isNull);
      expect(actuals.first.linkedPlanId, isNull);
      expect(snapshot.comparisonSlots.any((s) => s.orphanActual), isTrue);
    });
  });
}
