import 'package:intl/intl.dart';
import '../../../data/local/database.dart';

class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  static const _daysBack = 7;

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // ── Markdown ─────────────────────────────────────────────────

  Future<String> buildMarkdown() async {
    final buf = StringBuffer();
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final since = DateFormat('yyyy-MM-dd')
        .format(now.subtract(Duration(days: _daysBack - 1)));

    buf.writeln('# 时间管理手账 导出');
    buf.writeln('> 导出时间：${DateFormat('yyyy-MM-dd HH:mm').format(now)}');
    buf.writeln('> 范围：$since — $todayStr');
    buf.writeln();

    // Journal
    buf.writeln('## 手账');
    buf.writeln('| 日期 | 笔记 |');
    buf.writeln('| --- | --- |');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final journal = await _db.journalForDate(d);
      final note = journal?.notes.isNotEmpty == true
          ? journal!.notes.replaceAll('\n', ' ')
          : '—';
      buf.writeln('| $d | $note |');
    }
    buf.writeln();

    // Todos
    buf.writeln('## 待办');
    buf.writeln('| 日期 | 待办 | 状态 |');
    buf.writeln('| --- | --- | --- |');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final todos = await _db.todosForDate(d);
      for (final t in todos) {
        if (t.content.trim().isEmpty) continue;
        buf.writeln('| $d | ${t.content.trim()} | ${t.completed ? "✅" : "❌"} |');
      }
    }
    buf.writeln();

    // Time blocks
    buf.writeln('## 时段');
    buf.writeln('| 日期 | 开始 | 结束 | 内容 | 类型 |');
    buf.writeln('| --- | --- | --- | --- | --- |');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final blocks = [
        ...await _db.blocksForDate(d, 'planned'),
        ...await _db.blocksForDate(d, 'actual'),
      ]..sort((a, b) => a.startTime.compareTo(b.startTime));
      for (final b in blocks) {
        if (b.content.trim().isEmpty) continue;
        final type = b.source == 'planned' ? '计划' : '实际';
        buf.writeln(
            '| $d | ${b.startTime} | ${b.endTime} | ${b.content.trim()} | $type |');
      }
    }
    buf.writeln();

    // Pomodoro
    buf.writeln('## 专注');
    buf.writeln('| 日期 | 时长 | 实际 | 状态 |');
    buf.writeln('| --- | --- | --- | --- |');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final sessions = await _db.sessionsForDate(d);
      for (final s in sessions) {
        final dur = '${s.durationMinutes} 分钟';
        final act = s.completed ? '${(s.actualSeconds / 60).round()} 分钟' : '—';
        final st = s.completed ? '完成' : '放弃';
        buf.writeln('| $d | $dur | $act | $st |');
      }
    }
    buf.writeln();

    // Sleep
    buf.writeln('## 睡眠');
    buf.writeln('| 日期 | 就寝 | 起床 | 得分 |');
    buf.writeln('| --- | --- | --- | --- |');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final sleep = await _db.sleepForDate(d);
      if (sleep == null) continue;
      final bed = sleep.actualBedtime != null
          ? DateFormat('HH:mm').format(sleep.actualBedtime!)
          : '—';
      final wake = sleep.actualWakeTime != null
          ? DateFormat('HH:mm').format(sleep.actualWakeTime!)
          : '—';
      buf.writeln('| $d | $bed | $wake | ${sleep.sleepScore} 分 |');
    }
    buf.writeln();

    // Weekly reflections
    buf.writeln('## 周小结');
    buf.writeln('| 周 | 笔记 |');
    buf.writeln('| --- | --- |');
    final reflections = await _db.select(_db.weeklyReflections).get();
    for (final r in reflections) {
      if (r.note.trim().isEmpty) continue;
      buf.writeln('| ${r.weekMonday} | ${r.note.replaceAll('\n', ' ')} |');
    }
    if (reflections.every((r) => r.note.trim().isEmpty)) {
      buf.writeln('| — | — |');
    }
    buf.writeln();

    return buf.toString();
  }

  // ── CSV ──────────────────────────────────────────────────────

  Future<String> buildCsv() async {
    final buf = StringBuffer();
    final now = DateTime.now();
    final since = DateFormat('yyyy-MM-dd')
        .format(now.subtract(Duration(days: _daysBack - 1)));

    buf.writeln('# 时间管理手账 CSV 导出');
    buf.writeln('# 导出时间：${DateFormat('yyyy-MM-dd HH:mm').format(now)}');
    buf.writeln('# 范围：$since — ${DateFormat('yyyy-MM-dd').format(now)}');
    buf.writeln();

    // todos.csv
    buf.writeln('## todos.csv');
    buf.writeln('日期,内容,完成');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final todos = await _db.todosForDate(d);
      for (final t in todos) {
        if (t.content.trim().isEmpty) continue;
        final content = _escapeCsv(t.content.trim());
        buf.writeln('$d,$content,${t.completed}');
      }
    }
    buf.writeln();

    // time_blocks.csv
    buf.writeln('## time_blocks.csv');
    buf.writeln('日期,开始,结束,内容,类型');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final blocks = [
        ...await _db.blocksForDate(d, 'planned'),
        ...await _db.blocksForDate(d, 'actual'),
      ]..sort((a, b) => a.startTime.compareTo(b.startTime));
      for (final b in blocks) {
        if (b.content.trim().isEmpty) continue;
        final content = _escapeCsv(b.content.trim());
        buf.writeln('$d,${b.startTime},${b.endTime},$content,${b.source}');
      }
    }
    buf.writeln();

    // pomodoro_sessions.csv
    buf.writeln('## pomodoro_sessions.csv');
    buf.writeln('日期,设定分钟,实际秒,完成,中断次数');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final sessions = await _db.sessionsForDate(d);
      for (final s in sessions) {
        buf.writeln(
            '$d,${s.durationMinutes},${s.actualSeconds},${s.completed},${s.interruptCount}');
      }
    }
    buf.writeln();

    // sleep_records.csv
    buf.writeln('## sleep_records.csv');
    buf.writeln('日期,目标就寝,目标起床,实际就寝,实际起床,得分,连续天数');
    for (var i = _daysBack - 1; i >= 0; i--) {
      final d = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      final sleep = await _db.sleepForDate(d);
      if (sleep == null) continue;
      final ab = sleep.actualBedtime != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(sleep.actualBedtime!)
          : '';
      final aw = sleep.actualWakeTime != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(sleep.actualWakeTime!)
          : '';
      buf.writeln(
          '$d,${sleep.targetBedtime},${sleep.targetWakeTime},$ab,$aw,${sleep.sleepScore},${sleep.streakDays}');
    }
    buf.writeln();

    return buf.toString();
  }
}
