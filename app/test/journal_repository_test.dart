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

  group('reorderTodos', () {
    test('reorders three todos correctly', () async {
      const date = '2026-07-04';
      await repository.createTodo(date, 'A');
      await repository.createTodo(date, 'B');
      await repository.createTodo(date, 'C');

      // Move A (index 0) to after C (index 2)
      await repository.reorderTodos(date, 0, 2);

      final snapshot = await repository.load(date);
      final names = snapshot.todos.map((t) => t.content).toList();
      expect(names, ['B', 'C', 'A']);
    });

    test('out of bounds indices are silently ignored', () async {
      const date = '2026-07-04';
      await repository.createTodo(date, 'A');
      await repository.createTodo(date, 'B');

      // Both indices out of range — should not throw
      await repository.reorderTodos(date, 5, 10);

      final snapshot = await repository.load(date);
      expect(snapshot.todos, hasLength(2));
    });

    test('scoped reorder only updates sort order within scope', () async {
      const date = '2026-07-04';
      final a = await repository.createTodo(date, 'A');
      final b = await repository.createTodo(date, 'B');
      final c = await repository.createTodo(date, 'C');
      await repository.updateTodo(a.copyWith(completed: true));

      await repository.reorderTodos(
        date,
        0,
        1,
        scopedTodoIds: [b.id, c.id],
      );

      final snapshot = await repository.load(date);
      final openTodos = snapshot.todos
          .where((todo) => !todo.completed)
          .map((todo) => todo.content)
          .toList();
      expect(openTodos, ['C', 'B']);
      expect(snapshot.todos.singleWhere((todo) => todo.completed).content, 'A');
    });

    test('scoped reorder assigns unique global sortOrder across full list', () async {
      const date = '2026-07-04';
      final a = await repository.createTodo(date, 'A');
      final b = await repository.createTodo(date, 'B');
      final c = await repository.createTodo(date, 'C');

      await repository.reorderTodos(
        date,
        0,
        2,
        scopedTodoIds: [a.id, b.id, c.id],
      );

      final snapshot = await repository.load(date);
      final orders = snapshot.todos.map((todo) => todo.sortOrder).toList();
      expect(orders, [0, 1, 2]);
      expect(
        snapshot.todos.map((todo) => todo.content).toList(),
        ['B', 'C', 'A'],
      );
    });

    test(
      'scoped reorder keeps excluded todos in place without sortOrder collisions',
      () async {
        const date = '2026-07-04';
        final a = await repository.createTodo(date, 'A');
        final b = await repository.createTodo(date, 'B');
        final c = await repository.createTodo(date, 'C');
        final d = await repository.createTodo(date, 'D');
        final e = await repository.createTodo(date, 'E');

        await repository.updateTodo(a.copyWith(completed: true, sortOrder: 0));
        await repository.updateTodo(b.copyWith(sortOrder: 1));
        await repository.updateTodo(c.copyWith(completed: true, sortOrder: 2));
        await repository.updateTodo(d.copyWith(sortOrder: 3));
        await repository.updateTodo(e.copyWith(sortOrder: 4));

        await repository.reorderTodos(
          date,
          0,
          2,
          scopedTodoIds: [b.id, d.id, e.id],
        );

        final snapshot = await repository.load(date);
        final todos = snapshot.todos;
        expect(todos.map((todo) => todo.content).toList(), [
          'A',
          'D',
          'C',
          'E',
          'B',
        ]);
        expect(todos.map((todo) => todo.sortOrder).toList(), [0, 1, 2, 3, 4]);
        expect(
          todos.where((todo) => todo.completed).map((todo) => todo.content),
          ['A', 'C'],
        );
        expect(
          todos.where((todo) => !todo.completed).map((todo) => todo.content),
          ['D', 'E', 'B'],
        );
      },
    );
  });
}
