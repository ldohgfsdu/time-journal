import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';
import '../../../app/copy.dart';

/// 未闭合就寝记录的最大可补全窗口，避免误补几天前忘记关掉的 bedtime。
const sleepOpenBedtimeMaxAge = Duration(hours: 24);

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
  final now = DateTime.now();
  final record = await resolveSleepDisplayRecord(db, now: now);
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

Future<SleepRecord?> findRecentBedtimeRecordNear(
  AppDatabase db, {
  required DateTime referenceTime,
}) async {
  final all = await db.select(db.sleepRecords).get();
  final candidates = all
      .where((record) => record.actualBedtime != null)
      .toList()
    ..sort(
      (a, b) => b.actualBedtime!.compareTo(a.actualBedtime!),
    );

  for (final record in candidates) {
    final bedtime = record.actualBedtime!;
    if (!referenceTime.isAfter(bedtime)) continue;
    if (referenceTime.difference(bedtime) > sleepOpenBedtimeMaxAge) continue;
    return record;
  }
  return null;
}

Future<SleepRecord> resolveSleepDisplayRecord(
  AppDatabase db, {
  required DateTime now,
}) async {
  final today = DateFormat('yyyy-MM-dd').format(now);
  final todayRecord = await db.sleepForDate(today);
  if (todayRecord != null &&
      (todayRecord.actualBedtime != null ||
          todayRecord.actualWakeTime != null)) {
    return todayRecord;
  }

  final recent = await findRecentBedtimeRecordNear(db, referenceTime: now);
  if (recent != null) {
    return recent;
  }

  return db.ensureSleepRecord(today);
}

Future<void> checkInWakeTime(AppDatabase db, {DateTime? now}) async {
  final wakeTime = now ?? DateTime.now();
  final target = await findRecentBedtimeRecordNear(db, referenceTime: wakeTime) ??
      await db.ensureSleepRecord(DateFormat('yyyy-MM-dd').format(wakeTime));
  await (db.update(db.sleepRecords)
        ..where((t) => t.id.equals(target.id)))
      .write(SleepRecordsCompanion(actualWakeTime: Value(wakeTime)));
}

Future<String> checkInBedtime(AppDatabase db, {DateTime? now}) async {
  final bedtime = now ?? DateTime.now();
  final date = DateFormat('yyyy-MM-dd').format(bedtime);
  final record = await db.ensureSleepRecord(date);
  final score = calculateSleepScore(
    targetBedtime: record.targetBedtime,
    actualBedtime: bedtime,
  );
  final yesterday =
      DateFormat('yyyy-MM-dd').format(bedtime.subtract(const Duration(days: 1)));
  final yesterdayRecord = await db.sleepForDate(yesterday);
  final newStreak = score >= 5 ? (yesterdayRecord?.streakDays ?? 0) + 1 : 0;
  final bonus = newStreak > 1 ? 2 : 0;
  final total = record.totalScore + score + bonus;
  await db.upsertSleepRecord(SleepRecordsCompanion(
    date: Value(date),
    actualBedtime: Value(bedtime),
    sleepScore: Value(score),
    streakDays: Value(newStreak),
    totalScore: Value(total),
  ));
  return AppCopy.sleepCheckInFeedback(score, newStreak);
}

String? formatSleepDuration({
  required DateTime? actualBedtime,
  required DateTime? actualWakeTime,
}) {
  if (actualBedtime == null || actualWakeTime == null) return null;
  var duration = actualWakeTime.difference(actualBedtime);
  if (duration.isNegative) {
    duration =
        actualWakeTime.add(const Duration(days: 1)).difference(actualBedtime);
  }
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours == 0 && minutes == 0) return '不足 1 分钟';
  if (hours == 0) return '$minutes 分钟';
  if (minutes == 0) return '$hours 小时';
  return '$hours 小时 $minutes 分钟';
}


