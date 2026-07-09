/// 周总结聚合模型 —— drift 层计算后吐给 UI，视图只做展示
class WeekRange {
  const WeekRange({
    required this.monday,
    required this.weekNumber,
    required this.label,
    required this.dateKeys,
  });

  final DateTime monday;
  final int weekNumber;
  final String label;
  final List<String> dateKeys;
}

class DayActivity {
  const DayActivity({
    required this.date,
    required this.weekdayLabel,
    required this.hasJournal,
    required this.focusMinutes,
    required this.earlySleep,
  });

  final String date;
  final String weekdayLabel;
  final bool hasJournal;
  final int focusMinutes;
  final bool earlySleep;

  int get activityLevel {
    var n = 0;
    if (hasJournal) n++;
    if (focusMinutes > 0) n++;
    if (earlySleep) n++;
    return n;
  }
}

class WeeklySummary {
  const WeeklySummary({
    required this.week,
    required this.attendanceDays,
    required this.journalDays,
    required this.plannedStudyMinutes,
    required this.actualStudyMinutes,
    required this.focusSessions,
    required this.focusMinutes,
    required this.earlySleepDays,
    required this.sleepNights,
    required this.starsLit,
    required this.days,
    this.avgBedtimeLabel,
    this.prevEarlySleepDays,
    this.prevFocusMinutes,
    this.topFocusPresetMinutes,
    this.reflectionNote = '',
  });

  final WeekRange week;
  final int attendanceDays;
  final int journalDays;
  final int plannedStudyMinutes;
  final int actualStudyMinutes;
  final int focusSessions;
  /// 本周完成专注总秒数（字段名历史遗留，非「分钟」）。
  final int focusMinutes;
  final int earlySleepDays;
  final int sleepNights;
  final int starsLit;
  final List<DayActivity> days;
  final String? avgBedtimeLabel;
  final int? prevEarlySleepDays;
  /// 上周完成专注总秒数。
  final int? prevFocusMinutes;
  final int? topFocusPresetMinutes;
  final String reflectionNote;

  int get focusSeconds => focusMinutes;

  int? get earlySleepDelta =>
      prevEarlySleepDays == null ? null : earlySleepDays - prevEarlySleepDays!;

  int? get focusSecondsDelta =>
      prevFocusMinutes == null ? null : focusMinutes - prevFocusMinutes!;

  @Deprecated('use focusSecondsDelta')
  int? get focusMinutesDelta => focusSecondsDelta;
}