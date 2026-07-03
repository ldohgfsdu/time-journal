import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/app/notification_service.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/local/database_provider.dart';
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
    test('readyForNextRound is true after break ends', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      // Simulate break ending by calling phase-complete twice.
      await controller.onPhaseComplete(); // focus → break
      await controller.onPhaseComplete(); // break → ready

      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, true);
    });

    test('startNextRound begins a new focus session', () async {
      controller.setLinkedTask('背单词');
      controller.selectMinutes(25);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → break
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
      await controller.onPhaseComplete(); // focus → break
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
      await controller.onPhaseComplete(); // focus → break
      await controller.onPhaseComplete(); // break → ready

      expect(controller.state.readyForNextRound, true);

      await controller.abandon();
      expect(controller.state.readyForNextRound, false);
      expect(controller.state.phase, PomodoroPhase.idle);
    });

    test('pause is no-op in readyForNextRound state', () async {
      controller.selectMinutes(5);
      await controller.startFocus();
      await controller.onPhaseComplete(); // focus → break
      await controller.onPhaseComplete(); // break → ready

      controller.pause();
      expect(controller.state.readyForNextRound, true);
      expect(controller.state.isPaused, false);
    });

    test('completion feedback does not break state transitions', () async {
      controller.selectMinutes(5);
      await controller.startFocus();

      // focus → break: feedback fires, state still transitions correctly
      await controller.onPhaseComplete();
      expect(controller.state.phase, PomodoroPhase.breakTime);

      // break → ready: feedback fires, state still transitions correctly
      await controller.onPhaseComplete();
      expect(controller.state.phase, PomodoroPhase.idle);
      expect(controller.state.readyForNextRound, true);
    });
  });
}
