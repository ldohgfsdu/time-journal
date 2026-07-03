import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/repositories/journal_repository.dart';

void main() {
  late AppDatabase db;
  late JournalRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = JournalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'purgeEmptyRecords removes empty todos and keeps written todos',
    () async {
      const date = '2026-06-25';
      await repository.createTodo(date, '');
      await repository.createTodo(date, '复习高数');

      await repository.purgeEmptyRecords(date);

      final snapshot = await repository.load(date);
      expect(snapshot.todos.map((todo) => todo.content), ['复习高数']);
    },
  );

  test(
    'purgeEmptyRecords removes empty blocks and keeps comparison slots',
    () async {
      const date = '2026-06-25';
      await repository.addBlock(date, 'planned');
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '09:00',
        endTime: '10:00',
        content: '背单词',
      );
      await repository.completePlannedAsActual(date, planned);

      await repository.purgeEmptyRecords(date);

      final snapshot = await repository.load(date);
      expect(snapshot.plannedBlocks.map((block) => block.content), ['背单词']);
      expect(snapshot.actualBlocks.map((block) => block.content), ['背单词']);
      expect(snapshot.comparisonSlots, hasLength(1));
    },
  );

  test('load reads journal data without purging empty records', () async {
    const date = '2026-06-25';
    await repository.createTodo(date, '');

    final snapshot = await repository.load(date);

    expect(snapshot.todos, hasLength(1));
    expect(snapshot.todos.single.content, isEmpty);
  });

  test('addActualFromPomodoro writes actual block with linkedTodoId', () async {
    const date = '2026-06-25';
    await repository.addActualFromPomodoro(
      date: date,
      startTime: '14:00',
      endTime: '14:25',
      content: '复习高数',
      linkedTodoId: 42,
    );

    final snapshot = await repository.load(date);
    expect(snapshot.actualBlocks, hasLength(1));
    final block = snapshot.actualBlocks.single;
    expect(block.source, 'actual');
    expect(block.content, '复习高数');
    expect(block.startTime, '14:00');
    expect(block.endTime, '14:25');
    expect(block.linkedTodoId, 42);
  });

  test(
    'addActualFromPomodoro works without linkedTodoId for manual tasks',
    () async {
      const date = '2026-06-25';
      await repository.addActualFromPomodoro(
        date: date,
        startTime: '10:00',
        endTime: '10:25',
        content: '临时任务',
      );

      final snapshot = await repository.load(date);
      expect(snapshot.actualBlocks, hasLength(1));
      expect(snapshot.actualBlocks.single.linkedTodoId, isNull);
    },
  );
}
