import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class SleepViewData {
  const SleepViewData({
    required this.record,
    required this.streakDays,
    required this.totalScore,
  });

  final SleepRecord record;
  final int streakDays;
  final int totalScore;
}

int calculateSleepScore({
  required String targetBedtime,
  required DateTime? actualBedtime,
}) {
  if (actualBedtime == null) return 0;
  final target = _parseTodayTime(targetBedtime, actualBedtime);
  final diff = actualBedtime.difference(target).inMinutes;
  if (diff.abs() <= 15) return 10;
  if (diff.abs() <= 30) return 5;
  if (diff > 30 && diff <= 60) return 0;
  return 0;
}

DateTime _parseTodayTime(String hhmm, DateTime reference) {
  final parts = hhmm.split(':');
  return DateTime(reference.year, reference.month, reference.day, int.parse(parts[0]), int.parse(parts[1]));
}

final sleepDataProvider = FutureProvider.autoDispose<SleepViewData>((ref) async {
  final db = ref.watch(databaseProvider);
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final record = await db.ensureSleepRecord(date);
  final all = await db.select(db.sleepRecords).get();
  final totalScore = all.fold<int>(0, (sum, r) => sum + r.sleepScore);
  return SleepViewData(record: record, streakDays: record.streakDays, totalScore: totalScore);
});

Future<void> updateSleepSchedule(WidgetRef ref, {required String bedtime, required String wakeTime}) async {
  final db = ref.read(databaseProvider);
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  await db.upsertSleepRecord(SleepRecordsCompanion(
    date: Value(date),
    targetBedtime: Value(bedtime),
    targetWakeTime: Value(wakeTime),
  ));
  ref.invalidate(sleepDataProvider);
}

Future<void> checkInBedtime(WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final now = DateTime.now();
  final date = DateFormat('yyyy-MM-dd').format(now);
  final record = await db.ensureSleepRecord(date);
  final score = calculateSleepScore(targetBedtime: record.targetBedtime, actualBedtime: now);
  final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
  final yesterdayRecord = await db.sleepForDate(yesterday);
  final newStreak = score >= 5 ? (yesterdayRecord?.streakDays ?? 0) + 1 : 0;
  final bonus = newStreak > 1 ? 2 : 0;
  final total = record.totalScore + score + bonus;
  await db.upsertSleepRecord(SleepRecordsCompanion(
    date: Value(date),
    actualBedtime: Value(now),
    sleepScore: Value(score),
    streakDays: Value(newStreak),
    totalScore: Value(total),
  ));
  ref.invalidate(sleepDataProvider);
}
