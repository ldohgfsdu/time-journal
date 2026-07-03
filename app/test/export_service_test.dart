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
}
