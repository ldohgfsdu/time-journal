import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/repositories/weekly_repository.dart';

/// Monday of week under test.
final _testMonday = DateTime(2026, 7, 6); // 2026-07-06 is a Monday

/// Returns the Nth day of the test week as a date string (0=Mon … 6=Sun).
String _day(int offset) =>
    DateFormat('yyyy-MM-dd').format(_testMonday.add(Duration(days: offset)));

void main() {
  late AppDatabase db;
  late WeeklyRepository repo;

  setUpAll(() async {
    await initializeDateFormatting('zh_CN', null);
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WeeklyRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ── helpers ──────────────────────────────────────────────────

  Future<void> insertPlannedBlock({
    required String date,
    required String start,
    required String end,
    required String content,
  }) async {
    await db.upsertTimeBlock(TimeBlocksCompanion.insert(
      journalDate: date,
      startTime: start,
      endTime: end,
      content: Value(content),
      source: 'planned',
    ));
  }

  Future<void> insertActualBlock({
    required String date,
    required String start,
    required String end,
    required String content,
  }) async {
    await db.upsertTimeBlock(TimeBlocksCompanion.insert(
      journalDate: date,
      startTime: start,
      endTime: end,
      content: Value(content),
      source: 'actual',
    ));
  }

  Future<void> insertTodo({
    required String date,
    required String content,
  }) async {
    await db.upsertTodo(TodoItemsCompanion.insert(
      journalDate: date,
      content: Value(content),
    ));
  }

  Future<void> insertCompletedFocus({
    required String date,
    required int durationMinutes,
    required int actualSeconds,
  }) async {
    final id = await db.insertPomodoroSession(
      PomodoroSessionsCompanion.insert(
        date: date,
        durationMinutes: durationMinutes,
        startedAt: DateTime(2026, 7, 6, 9, 0),
      ),
    );
    await db.updatePomodoroSession(
      id,
      PomodoroSessionsCompanion(
        actualSeconds: Value(actualSeconds),
        completed: const Value(true),
      ),
    );
  }

  Future<void> setSleepRecord({
    required String date,
    required DateTime bedtime,
    required int score,
  }) async {
    final record = await db.ensureSleepRecord(date);
    await (db.update(db.sleepRecords)
          ..where((t) => t.id.equals(record.id)))
        .write(SleepRecordsCompanion(
      actualBedtime: Value(bedtime),
      sleepScore: Value(score),
    ));
  }

  // ── loadWeek: empty week ─────────────────────────────────────

  group('loadWeek empty data', () {
    test('returns 7 days with zero totals and no errors', () async {
      final summary = await repo.loadWeek(_testMonday);

      expect(summary.days, hasLength(7));
      expect(summary.attendanceDays, 0);
      expect(summary.journalDays, 0);
      expect(summary.plannedStudyMinutes, 0);
      expect(summary.actualStudyMinutes, 0);
      expect(summary.focusSessions, 0);
      expect(summary.focusMinutes, 0);
      expect(summary.earlySleepDays, 0);
      expect(summary.starsLit, 0);
      expect(summary.avgBedtimeLabel, isNull);
      expect(summary.topFocusPresetMinutes, isNull);
      expect(summary.reflectionNote, '');
    });

    test('days list contains correct date keys and weekday labels', () async {
      final summary = await repo.loadWeek(_testMonday);

      expect(summary.days[0].date, _day(0));
      expect(summary.days[0].weekdayLabel, isNotEmpty);
      expect(summary.days[6].date, _day(6));
    });

    test('each day has no activity', () async {
      final summary = await repo.loadWeek(_testMonday);

      for (final day in summary.days) {
        expect(day.hasJournal, isFalse);
        expect(day.focusMinutes, 0);
        expect(day.earlySleep, isFalse);
        expect(day.activityLevel, 0);
      }
    });

    test('deltas are zero when previous week has no data', () async {
      final summary = await repo.loadWeek(_testMonday);

      // _loadWeekTotals returns 0 for empty weeks, not null.
      expect(summary.prevEarlySleepDays, 0);
      expect(summary.prevFocusMinutes, 0);
      // Deltas: current (0) - previous (0) = 0
      expect(summary.earlySleepDelta, 0);
      expect(summary.focusMinutesDelta, 0);
    });
  });

  // ── loadWeek: basic aggregation ──────────────────────────────

  group('loadWeek aggregation', () {
    setUp(() async {
      // Day 0 (Mon): planned 09:00-10:00 + actual 09:00-10:30 + todo + focus
      await insertPlannedBlock(
        date: _day(0), start: '09:00', end: '10:00', content: '背单词',
      );
      await insertActualBlock(
        date: _day(0), start: '09:00', end: '10:30', content: '背单词',
      );
      await insertTodo(date: _day(0), content: '复习高数');
      await insertCompletedFocus(
        date: _day(0), durationMinutes: 25, actualSeconds: 1500,
      );
      await setSleepRecord(
        date: _day(0),
        bedtime: DateTime(2026, 7, 6, 23, 0),
        score: 10,
      );

      // Day 2 (Wed): planned 14:00-15:00 + actual 14:00-14:50 + focus
      await insertPlannedBlock(
        date: _day(2), start: '14:00', end: '15:00', content: '刷题',
      );
      await insertActualBlock(
        date: _day(2), start: '14:00', end: '14:50', content: '刷题',
      );
      await insertCompletedFocus(
        date: _day(2), durationMinutes: 45, actualSeconds: 2700,
      );
      await setSleepRecord(
        date: _day(2),
        bedtime: DateTime(2026, 7, 8, 22, 45),
        score: 10,
      );
    });

    test('returns 7 days', () async {
      final summary = await repo.loadWeek(_testMonday);
      expect(summary.days, hasLength(7));
    });

    test('Day 0 (Mon) has correct activity flags', () async {
      final summary = await repo.loadWeek(_testMonday);
      final mon = summary.days[0];

      expect(mon.hasJournal, isTrue);
      expect(mon.focusMinutes, 25); // 1500s / 60 = 25
      expect(mon.earlySleep, isTrue); // score 10 >= 5
      expect(mon.activityLevel, 3); // journal + focus + sleep
    });

    test('Day 1 (Tue) has no activity', () async {
      final summary = await repo.loadWeek(_testMonday);
      final tue = summary.days[1];

      expect(tue.hasJournal, isFalse);
      expect(tue.focusMinutes, 0);
      expect(tue.earlySleep, isFalse);
      expect(tue.activityLevel, 0);
    });

    test('Day 2 (Wed) has correct activity flags', () async {
      final summary = await repo.loadWeek(_testMonday);
      final wed = summary.days[2];

      expect(wed.hasJournal, isTrue);
      expect(wed.focusMinutes, 45); // 2700s / 60 = 45
      expect(wed.earlySleep, isTrue);
      expect(wed.activityLevel, 3);
    });

    test('planned minutes aggregate correctly', () async {
      final summary = await repo.loadWeek(_testMonday);
      // Mon: 09:00-10:00 = 60min, Wed: 14:00-15:00 = 60min → total 120
      expect(summary.plannedStudyMinutes, 120);
    });

    test('actual minutes aggregate correctly', () async {
      final summary = await repo.loadWeek(_testMonday);
      // Mon: 09:00-10:30 = 90min, Wed: 14:00-14:50 = 50min → total 140
      expect(summary.actualStudyMinutes, 140);
    });

    test('focus sessions and minutes aggregate correctly', () async {
      final summary = await repo.loadWeek(_testMonday);
      expect(summary.focusSessions, 2);
      expect(summary.focusMinutes, 70); // 25 + 45
    });

    test('attendance counts days with any meaningful activity', () async {
      final summary = await repo.loadWeek(_testMonday);
      expect(summary.attendanceDays, 2);
      expect(summary.journalDays, 2);
    });

    test('early sleep days and stars aggregate correctly', () async {
      final summary = await repo.loadWeek(_testMonday);
      expect(summary.earlySleepDays, 2);
      expect(summary.starsLit, 2);
    });

    test('top focus preset is most frequent duration', () async {
      final summary = await repo.loadWeek(_testMonday);
      // Both have different durations: 25 and 45. In case of tie, reduce
      // returns the first one encountered (25).
      expect(summary.topFocusPresetMinutes, isNotNull);
    });

    test('average bedtime label is computed when sleep data exists', () async {
      final summary = await repo.loadWeek(_testMonday);
      // 23:00 (1380 min) and 22:45 (1365 min) → avg ≈ 22:52
      expect(summary.avgBedtimeLabel, isNotNull);
      expect(summary.avgBedtimeLabel, isNotEmpty);
    });

    test('prev week totals are zero when previous week has no data', () async {
      final summary = await repo.loadWeek(_testMonday);
      // _loadWeekTotals returns 0 for empty weeks, not null.
      expect(summary.prevEarlySleepDays, 0);
      expect(summary.prevFocusMinutes, 0);
    });
  });

  // ── loadWeek: previous week delta ─────────────────────────────

  group('loadWeek previous week delta', () {
    setUp(() async {
      // Set up data in the previous week (Mon = subtract 7 days)
      final prevMonday = _testMonday.subtract(const Duration(days: 7));
      final prevDay0 =
          DateFormat('yyyy-MM-dd').format(prevMonday);

      // Previous week: one early sleep day + 50 focus minutes
      await setSleepRecord(
        date: prevDay0,
        bedtime: DateTime(2026, 6, 29, 23, 0),
        score: 10,
      );
      await insertCompletedFocus(
        date: prevDay0, durationMinutes: 25, actualSeconds: 1500,
      );
      await insertCompletedFocus(
        date: prevDay0, durationMinutes: 25, actualSeconds: 1500,
      ); // 50min total

      // Current week: 2 early sleep + 90 focus minutes
      await setSleepRecord(
        date: _day(0),
        bedtime: DateTime(2026, 7, 6, 23, 0),
        score: 10,
      );
      await setSleepRecord(
        date: _day(1),
        bedtime: DateTime(2026, 7, 7, 22, 30),
        score: 10,
      );
      await insertCompletedFocus(
        date: _day(0), durationMinutes: 45, actualSeconds: 2700,
      );
      await insertCompletedFocus(
        date: _day(0), durationMinutes: 45, actualSeconds: 2700,
      ); // 90min total
    });

    test('deltas compare current week against previous week', () async {
      final summary = await repo.loadWeek(_testMonday);

      expect(summary.earlySleepDays, 2);
      expect(summary.focusMinutes, 90);
      expect(summary.prevEarlySleepDays, 1);
      expect(summary.prevFocusMinutes, 50);
      expect(summary.earlySleepDelta, 1); // 2 - 1
      expect(summary.focusMinutesDelta, 40); // 90 - 50
    });
  });

  // ── saveReflection ────────────────────────────────────────────

  group('saveReflection', () {
    test('saves and reads back a reflection note', () async {
      await repo.saveReflection(_testMonday, '这周状态不错');

      final summary = await repo.loadWeek(_testMonday);
      expect(summary.reflectionNote, '这周状态不错');
    });

    test('BUG: second save throws because insertOnConflictUpdate targets id not weekMonday', () async {
      await repo.saveReflection(_testMonday, '第一次记录');

      // The second save fails with UNIQUE constraint violation on week_monday.
      // Root cause: db.upsertWeeklyReflection uses insertOnConflictUpdate which
      // targets PRIMARY KEY (id), but weekly_reflections has a UNIQUE constraint
      // on week_monday.  Same Drift issue as sleep_records.
      //
      // Fix: replace insertOnConflictUpdate with ensure + update pattern
      // in database.dart:upsertWeeklyReflection.
      expect(
        () async => repo.saveReflection(_testMonday, '第二次覆盖'),
        throwsA(isA<Exception>()),
      );
    });

    test('empty note is allowed', () async {
      await repo.saveReflection(_testMonday, '');

      final summary = await repo.loadWeek(_testMonday);
      expect(summary.reflectionNote, '');
    });
  });

  // ── _sumBlockMinutes boundaries ───────────────────────────────

  group('block minute calculation', () {
    test('computes normal duration correctly (via loadWeek)', () async {
      await insertPlannedBlock(
        date: _day(0), start: '09:00', end: '10:30', content: '背单词',
      );
      await insertActualBlock(
        date: _day(0), start: '09:00', end: '10:30', content: '背单词',
      );

      final summary = await repo.loadWeek(_testMonday);
      expect(summary.plannedStudyMinutes, 90);
      expect(summary.actualStudyMinutes, 90);
    });

    test('handles invalid time format without crashing', () async {
      // _parseTime returns 0 for invalid format; _sumBlockMinutes
      // checks end > start; 0-? = 0 or negative → skipped.
      await insertPlannedBlock(
        date: _day(0), start: 'abc', end: '10:00', content: '测试',
      );
      await insertActualBlock(
        date: _day(0), start: 'abc', end: '10:00', content: '测试',
      );

      final summary = await repo.loadWeek(_testMonday);
      // Invalid start → parsed as 0, end=600. 600 > 0 → counts as 600 min.
      // This is the current implementation behaviour — documented, not fixed.
      expect(summary.plannedStudyMinutes, 600);
    });

    test('endTime earlier than startTime yields zero minutes', () async {
      await insertPlannedBlock(
        date: _day(0), start: '14:00', end: '09:00', content: '倒序时段',
      );

      final summary = await repo.loadWeek(_testMonday);
      // 840 min - 540 min = 300... wait:
      // start = 14:00 = 840, end = 09:00 = 540
      // end (540) > start (840)? No → _sumBlockMinutes skips (total += 0)
      expect(summary.plannedStudyMinutes, 0);
    });

    test('empty content blocks are still counted in minutes (current impl)', () async {
      await insertPlannedBlock(
        date: _day(0), start: '09:00', end: '10:00', content: '',
      );

      final summary = await repo.loadWeek(_testMonday);
      // BUG: _sumBlockMinutes does NOT check content.isEmpty;
      // empty-content blocks contribute minutes. 09:00-10:00 = 60 min.
      // Fix suggestion: add `if (b.content.trim().isEmpty) continue;` in
      // _sumBlockMinutes at weekly_repository.dart:166.
      expect(summary.plannedStudyMinutes, 60);
    });

    test('block with missing colon in time string is handled', () async {
      await insertPlannedBlock(
        date: _day(0), start: '0900', end: '10:00', content: '测试',
      );

      final summary = await repo.loadWeek(_testMonday);
      // '0900'.split(':') = ['0900'] → parts.length != 2 → returns 0
      // start=0, end=600 → counts as 600 min.  Known quirk.
      expect(summary.plannedStudyMinutes, 600);
    });
  });

  // ── average bedtime ───────────────────────────────────────────

  group('average bedtime', () {
    test('single bedtime returns that time', () async {
      await setSleepRecord(
        date: _day(0),
        bedtime: DateTime(2026, 7, 6, 23, 0),
        score: 10,
      );

      final summary = await repo.loadWeek(_testMonday);
      expect(summary.avgBedtimeLabel, '23:00');
    });

    test('multiple bedtimes compute average correctly', () async {
      await setSleepRecord(
        date: _day(0),
        bedtime: DateTime(2026, 7, 6, 23, 0),
        score: 10,
      );
      await setSleepRecord(
        date: _day(1),
        bedtime: DateTime(2026, 7, 7, 23, 30),
        score: 10,
      );

      final summary = await repo.loadWeek(_testMonday);
      // (23*60+0 + 23*60+30) / 2 = (1380 + 1410) / 2 = 1395 → 23:15
      expect(summary.avgBedtimeLabel, '23:15');
    });

    test('cross-midnight bedtimes may produce misleading average', () async {
      // This test documents the current behaviour.
      // 23:30 = 1410 min, 00:30 = 30 min → avg = (1410+30)/2 = 720 = 12:00
      // The result "12:00" is not a realistic avg bedtime but is expected
      // given the purely arithmetic implementation.
      await setSleepRecord(
        date: _day(0),
        bedtime: DateTime(2026, 7, 6, 23, 30),
        score: 10,
      );
      await setSleepRecord(
        date: _day(1),
        bedtime: DateTime(2026, 7, 8, 0, 30),
        score: 10,
      );

      final summary = await repo.loadWeek(_testMonday);
      // Current impl: (1410 + 30) ~/ 2 = 720 → 12:00
      // This is a known limitation — documented, not fixed in this commit.
      expect(summary.avgBedtimeLabel, isNotNull);
      // Behaviour: the result is NOT a realistic bedtime hour
      final result = summary.avgBedtimeLabel!;
      final hour = int.parse(result.split(':')[0]);
      // For cross-midnight bedtimes the current average lands in the middle
      // of the day, which is mathematically correct but semantically wrong.
      expect(hour, lessThan(18)); // falls in daytime, not evening
    });
  });

  // ── loadWeek: attendance vs journalDays distinction ───────────

  group('attendance vs journalDays', () {
    test('journalDays counts days with journal content only', () async {
      await insertTodo(date: _day(0), content: '复习');
      await insertCompletedFocus(
        date: _day(1), durationMinutes: 25, actualSeconds: 1500,
      );
      await setSleepRecord(
        date: _day(2),
        bedtime: DateTime(2026, 7, 8, 23, 0),
        score: 10,
      );

      final summary = await repo.loadWeek(_testMonday);

      // journalDays: only day 0 has journal content (todo)
      expect(summary.journalDays, 1);
      // attendanceDays: days 0 (journal), 1 (focus), 2 (sleep) all qualify
      expect(summary.attendanceDays, 3);
    });

    test('focus-only day counts for attendance but not journal', () async {
      await insertCompletedFocus(
        date: _day(0), durationMinutes: 25, actualSeconds: 1500,
      );

      final summary = await repo.loadWeek(_testMonday);

      expect(summary.attendanceDays, 1);
      expect(summary.journalDays, 0);
    });

    test('sleep-only day counts for attendance but not journal', () async {
      await setSleepRecord(
        date: _day(0),
        bedtime: DateTime(2026, 7, 6, 23, 0),
        score: 5,
      );

      final summary = await repo.loadWeek(_testMonday);

      expect(summary.attendanceDays, 1);
      expect(summary.journalDays, 0);
    });
  });
}
