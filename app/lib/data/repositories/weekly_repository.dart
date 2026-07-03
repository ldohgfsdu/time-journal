import 'package:intl/intl.dart';
import '../local/database.dart';
import '../models/weekly_summary.dart';

class WeeklyRepository {
  WeeklyRepository(this._db);

  final AppDatabase _db;

  static DateTime mondayOf(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.subtract(Duration(days: local.weekday - DateTime.monday));
  }

  static WeekRange weekRangeFor(DateTime monday) {
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final dateKeys =
        days.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();
    final label =
        '${DateFormat('M月d日').format(days.first)} — ${DateFormat('M月d日').format(days.last)}';
    return WeekRange(
      monday: monday,
      weekNumber: _isoWeekNumber(days.last),
      label: label,
      dateKeys: dateKeys,
    );
  }

  static int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - (date.weekday + 6) % 7));
    final yearStart = DateTime(thursday.year, 1, 1);
    return 1 + (thursday.difference(yearStart).inDays / 7).floor();
  }

  Future<WeeklySummary> loadWeek(DateTime monday) async {
    final week = weekRangeFor(monday);
    final prevMonday = monday.subtract(const Duration(days: 7));
    final prevWeek = weekRangeFor(prevMonday);

    final days = <DayActivity>[];
    var attendance = 0;
    var journalDays = 0;
    var plannedTotal = 0;
    var actualTotal = 0;
    var focusSessions = 0;
    var focusMinutes = 0;
    var earlySleepDays = 0;
    final bedtimeMinutes = <int>[];
    final presetCounts = <int, int>{};

    for (var i = 0; i < 7; i++) {
      final dateKey = week.dateKeys[i];
      final dayDate = week.monday.add(Duration(days: i));
      final weekdayLabel = DateFormat('E', 'zh_CN').format(dayDate);

      final journal = await _db.journalForDate(dateKey);
      final todos = await _db.todosForDate(dateKey);
      final planned = await _db.blocksForDate(dateKey, 'planned');
      final actual = await _db.blocksForDate(dateKey, 'actual');
      final sessions = await _db.sessionsForDate(dateKey);
      final sleep = await _db.sleepForDate(dateKey);

      final hasJournal = _hasJournalContent(
        journal: journal,
        todos: todos,
        planned: planned,
        actual: actual,
      );
      final dayFocusMinutes = sessions
          .where((s) => s.completed)
          .fold<int>(0, (sum, s) => sum + (s.actualSeconds ~/ 60));
      final earlySleep = (sleep?.sleepScore ?? 0) >= 5;

      if (hasJournal) journalDays++;
      if (hasJournal || dayFocusMinutes > 0 || sleep?.actualBedtime != null) {
        attendance++;
      }
      if (earlySleep) earlySleepDays++;

      plannedTotal += _sumBlockMinutes(planned);
      actualTotal += _sumBlockMinutes(actual);

      for (final s in sessions.where((s) => s.completed)) {
        focusSessions++;
        presetCounts[s.durationMinutes] =
            (presetCounts[s.durationMinutes] ?? 0) + 1;
      }
      focusMinutes += dayFocusMinutes;

      if (sleep?.actualBedtime != null) {
        final bt = sleep!.actualBedtime!;
        bedtimeMinutes.add(bt.hour * 60 + bt.minute);
      }

      days.add(DayActivity(
        date: dateKey,
        weekdayLabel: weekdayLabel,
        hasJournal: hasJournal,
        focusMinutes: dayFocusMinutes,
        earlySleep: earlySleep,
      ));
    }

    final prevSummary = await _loadWeekTotals(prevWeek);
    final topPreset = presetCounts.entries.isEmpty
        ? null
        : presetCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final weekMondayKey = DateFormat('yyyy-MM-dd').format(week.monday);
    final reflection = await _db.reflectionForWeek(weekMondayKey);

    return WeeklySummary(
      week: week,
      attendanceDays: attendance,
      journalDays: journalDays,
      plannedStudyMinutes: plannedTotal,
      actualStudyMinutes: actualTotal,
      focusSessions: focusSessions,
      focusMinutes: focusMinutes,
      earlySleepDays: earlySleepDays,
      starsLit: earlySleepDays,
      days: days,
      avgBedtimeLabel: _formatAvgBedtime(bedtimeMinutes),
      prevEarlySleepDays: prevSummary.earlySleepDays,
      prevFocusMinutes: prevSummary.focusMinutes,
      topFocusPresetMinutes: topPreset,
      reflectionNote: reflection?.note ?? '',
    );
  }

  Future<void> saveReflection(DateTime monday, String note) async {
    final weekMonday = DateFormat('yyyy-MM-dd').format(monday);
    await _db.upsertWeeklyReflection(weekMonday, note);
  }

  Future<({int earlySleepDays, int focusMinutes})> _loadWeekTotals(
    WeekRange week,
  ) async {
    var earlySleepDays = 0;
    var focusMinutes = 0;
    for (final dateKey in week.dateKeys) {
      final sleep = await _db.sleepForDate(dateKey);
      if ((sleep?.sleepScore ?? 0) >= 5) earlySleepDays++;
      final sessions = await _db.sessionsForDate(dateKey);
      focusMinutes += sessions
          .where((s) => s.completed)
          .fold<int>(0, (sum, s) => sum + (s.actualSeconds ~/ 60));
    }
    return (earlySleepDays: earlySleepDays, focusMinutes: focusMinutes);
  }

  static bool _hasJournalContent({
    required DailyJournal? journal,
    required List<TodoItem> todos,
    required List<TimeBlock> planned,
    required List<TimeBlock> actual,
  }) {
    if (journal != null && journal.notes.trim().isNotEmpty) return true;
    if (todos.any((t) => t.content.trim().isNotEmpty)) return true;
    if (planned.any((b) => b.content.trim().isNotEmpty)) return true;
    if (actual.any((b) => b.content.trim().isNotEmpty)) return true;
    return false;
  }

  static int _sumBlockMinutes(List<TimeBlock> blocks) {
    var total = 0;
    for (final b in blocks) {
      if (b.content.trim().isEmpty) continue;
      final start = _parseTime(b.startTime);
      final end = _parseTime(b.endTime);
      if (end > start) total += end - start;
    }
    return total;
  }

  static int _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  static String? _formatAvgBedtime(List<int> minutes) {
    if (minutes.isEmpty) return null;
    final avg = minutes.reduce((a, b) => a + b) ~/ minutes.length;
    final h = avg ~/ 60;
    final m = avg % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}