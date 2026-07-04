import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/features/profile/services/export_service.dart';

void main() {
  late AppDatabase db;
  late ExportService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = ExportService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Markdown export', () {
    test('produces header and sections with empty data', () async {
      final md = await service.buildMarkdown();

      expect(md, contains('# 时间管理手账 导出'));
      expect(md, contains('导出时间'));
      expect(md, contains('## 手账'));
      expect(md, contains('## 待办'));
      expect(md, contains('## 时段'));
      expect(md, contains('## 专注'));
      expect(md, contains('## 睡眠'));
      expect(md, contains('## 周小结'));
    });

    test('includes todo content with completion status', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await db.upsertTodo(TodoItemsCompanion.insert(
        journalDate: today,
        content: Value('背单词'),
      ));
      // Mark the todo as completed
      final todos = await db.todosForDate(today);
      await (db.update(db.todoItems)..where((t) => t.id.equals(todos.first.id)))
          .write(const TodoItemsCompanion(completed: Value(true)));

      final md = await service.buildMarkdown();
      expect(md, contains('背单词'));
      expect(md, contains('✅'));
    });

    test('includes time blocks', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await db.upsertTimeBlock(TimeBlocksCompanion.insert(
        journalDate: today,
        startTime: '09:00',
        endTime: '10:00',
        content: Value('背单词'),
        source: 'planned',
      ));

      final md = await service.buildMarkdown();
      expect(md, contains('背单词'));
      expect(md, contains('09:00'));
      expect(md, contains('计划'));
    });
  });

  group('CSV export', () {
    test('produces headers and sections with empty data', () async {
      final csv = await service.buildCsv();

      expect(csv, contains('# 时间管理手账 CSV 导出'));
      expect(csv, contains('## todos.csv'));
      expect(csv, contains('## time_blocks.csv'));
      expect(csv, contains('## pomodoro_sessions.csv'));
      expect(csv, contains('## sleep_records.csv'));
    });

    test('escapes comma in content', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await db.upsertTodo(TodoItemsCompanion.insert(
        journalDate: today,
        content: Value('背单词, 复习高数'),
      ));

      final csv = await service.buildCsv();
      expect(csv, contains('"背单词, 复习高数"'));
    });

    test('escapes double quote in content', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await db.upsertTodo(TodoItemsCompanion.insert(
        journalDate: today,
        content: Value('5" 屏幕'),
      ));

      final csv = await service.buildCsv();
      expect(csv, contains('"5"" 屏幕"'));
    });

    test('empty data does not crash', () async {
      final csv = await service.buildCsv();
      expect(csv, isNotEmpty);
    });
  });

  group('sleep record filtering', () {
    test('completely empty sleep record excluded from Markdown', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await db.ensureSleepRecord(today);
      // Also insert a real sleep record to ensure table header is still there
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      final record = await db.ensureSleepRecord(yesterday);
      await (db.update(db.sleepRecords)
            ..where((t) => t.id.equals(record.id)))
          .write(SleepRecordsCompanion(
        actualBedtime: Value(DateTime(2026, 7, 3, 23, 0)),
      ));

      final md = await service.buildMarkdown();
      // Header exists
      expect(md, contains('## 睡眠'));
      // Empty record's date should NOT appear with a 0-score row
      expect(md, isNot(contains('$today | — | — | 0 分')));
      // Real record should appear
      expect(md, contains('23:00'));
    });

    test('completely empty sleep record excluded from CSV', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await db.ensureSleepRecord(today);
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      final record = await db.ensureSleepRecord(yesterday);
      await (db.update(db.sleepRecords)
            ..where((t) => t.id.equals(record.id)))
          .write(SleepRecordsCompanion(
        actualBedtime: Value(DateTime(2026, 7, 3, 23, 0)),
      ));

      final csv = await service.buildCsv();
      // Header exists
      expect(csv, contains('## sleep_records.csv'));
      // Real record has bedtime data
      expect(csv, contains('2026-07-03 23:00'));
    });

    test('sleep record with actualBedtime is kept in Markdown', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final record = await db.ensureSleepRecord(today);
      await (db.update(db.sleepRecords)
            ..where((t) => t.id.equals(record.id)))
          .write(SleepRecordsCompanion(
        actualBedtime: Value(DateTime(2026, 7, 4, 22, 30)),
      ));

      final md = await service.buildMarkdown();
      expect(md, contains('22:30'));
    });

    test('sleep record with actualWakeTime is kept in Markdown', () async {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final record = await db.ensureSleepRecord(today);
      await (db.update(db.sleepRecords)
            ..where((t) => t.id.equals(record.id)))
          .write(SleepRecordsCompanion(
        actualWakeTime: Value(DateTime(2026, 7, 4, 7, 0)),
      ));

      final md = await service.buildMarkdown();
      expect(md, contains('07:00'));
    });
  });
}
