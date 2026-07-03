import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/features/sleep/providers/sleep_provider.dart';

void main() {
  group('calculateSleepScore', () {
    test('gives full score within 15 minutes of bedtime target', () {
      final score = calculateSleepScore(
        targetBedtime: '23:00',
        actualBedtime: DateTime(2026, 6, 25, 23, 12),
      );

      expect(score, 10);
    });

    test('gives partial score within 30 minutes of bedtime target', () {
      final score = calculateSleepScore(
        targetBedtime: '23:00',
        actualBedtime: DateTime(2026, 6, 25, 23, 25),
      );

      expect(score, 5);
    });

    test('gives zero when bedtime is more than 30 minutes late', () {
      final score = calculateSleepScore(
        targetBedtime: '23:00',
        actualBedtime: DateTime(2026, 6, 25, 23, 31),
      );

      expect(score, 0);
    });
  });

  group('checkInWakeTime', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('writes actualWakeTime for today', () async {
      await checkInWakeTime(db);

      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final record = await db.sleepForDate(date);
      expect(record, isNotNull);
      expect(record!.actualWakeTime, isNotNull);
    });

    test('repeat call does not create duplicate record', () async {
      await checkInWakeTime(db);
      await checkInWakeTime(db);

      final all = await db.select(db.sleepRecords).get();
      expect(all.length, 1);
    });

    test('does not lose existing actualBedtime when writing wake time', () async {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final existing = await db.ensureSleepRecord(date);
      final bedtime = DateTime(2026, 6, 25, 23, 15);
      await (db.update(db.sleepRecords)
            ..where((t) => t.id.equals(existing.id)))
          .write(SleepRecordsCompanion(actualBedtime: Value(bedtime)));

      await checkInWakeTime(db);

      final record = await db.sleepForDate(date);
      expect(record, isNotNull);
      expect(record!.actualBedtime, isNotNull);
      expect(record.actualWakeTime, isNotNull);
    });
  });

  group('formatSleepDuration', () {
    test('returns null when actualBedtime is null', () {
      final result = formatSleepDuration(
        actualBedtime: null,
        actualWakeTime: DateTime(2026, 6, 26, 7, 0),
      );
      expect(result, isNull);
    });

    test('returns null when actualWakeTime is null', () {
      final result = formatSleepDuration(
        actualBedtime: DateTime(2026, 6, 25, 23, 0),
        actualWakeTime: null,
      );
      expect(result, isNull);
    });

    test('formats normal same-day sleep duration', () {
      final result = formatSleepDuration(
        actualBedtime: DateTime(2026, 6, 25, 23, 0),
        actualWakeTime: DateTime(2026, 6, 26, 7, 15),
      );
      expect(result, '8 小时 15 分钟');
    });

    test('formats cross-midnight sleep with wakeTime earlier in the day', () {
      // User went to bed at 23:00 on June 25, woke at 07:00 on June 26
      // actualWakeTime is 07:00 which is before midnight, but actualBedtime is 23:00
      // The difference is negative → cross-midnight handling kicks in
      final result = formatSleepDuration(
        actualBedtime: DateTime(2026, 6, 25, 23, 0),
        actualWakeTime: DateTime(2026, 6, 25, 7, 0), // early morning, same calendar date
      );
      // 23:00 → 07:00 next day = 8 hours
      expect(result, '8 小时');
    });

    test('formats minutes-only duration under one hour', () {
      final result = formatSleepDuration(
        actualBedtime: DateTime(2026, 6, 25, 23, 0),
        actualWakeTime: DateTime(2026, 6, 25, 23, 45),
      );
      expect(result, '45 分钟');
    });
  });
}
