import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/models/comparison_slot.dart';
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

  test(
    'addActualFromPomodoro is idempotent on duplicate call with same params',
    () async {
      const date = '2026-06-25';
      const params = (
        date: date,
        startTime: '14:00',
        endTime: '14:25',
        content: '复习高数',
        linkedTodoId: 42,
      );

      await repository.addActualFromPomodoro(
        date: params.date,
        startTime: params.startTime,
        endTime: params.endTime,
        content: params.content,
        linkedTodoId: params.linkedTodoId,
      );
      await repository.addActualFromPomodoro(
        date: params.date,
        startTime: params.startTime,
        endTime: params.endTime,
        content: params.content,
        linkedTodoId: params.linkedTodoId,
      );

      final snapshot = await repository.load(date);
      expect(snapshot.actualBlocks, hasLength(1));
      expect(snapshot.actualBlocks.single.content, '复习高数');
      expect(snapshot.actualBlocks.single.linkedTodoId, 42);
      expect(snapshot.actualBlocks.single.startTime, '14:00');
      expect(snapshot.actualBlocks.single.endTime, '14:25');
    },
  );

  test(
    'addActualFromPomodoro does not deduplicate different time slots',
    () async {
      const date = '2026-06-25';

      await repository.addActualFromPomodoro(
        date: date,
        startTime: '09:00',
        endTime: '09:25',
        content: '背单词',
        linkedTodoId: 1,
      );
      await repository.addActualFromPomodoro(
        date: date,
        startTime: '14:00',
        endTime: '14:25',
        content: '复习高数',
        linkedTodoId: 2,
      );

      final snapshot = await repository.load(date);
      expect(snapshot.actualBlocks, hasLength(2));
      final contents = snapshot.actualBlocks.map((b) => b.content).toSet();
      expect(contents, {'背单词', '复习高数'});
    },
  );

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

  group('P0-6 linkedPlanId matching', () {
    test('actual edited time remains paired with original planned block', () async {
      const date = '2026-07-06';
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '09:00',
        endTime: '10:00',
        content: '复习',
      );
      var slotActual = await repository.ensureActualSlot(date, planned);
      // set content (ensure creates empty slot for "实际有变")
      await repository.updateBlock(slotActual.copyWith(content: '复习'));

      // edit the actual time
      var snapshot = await repository.load(date);
      var actual = snapshot.actualBlocks.single;
      await repository.updateBlock(actual.copyWith(
        startTime: '09:20',
        endTime: '10:10',
      ));

      // reload
      snapshot = await repository.load(date);
      expect(snapshot.comparisonSlots, hasLength(1));
      final slot = snapshot.comparisonSlots.single;
      expect(slot.planned, isNotNull);
      expect(slot.actual, isNotNull);
      expect(slot.actual!.startTime, '09:20');
      expect(slot.actual!.endTime, '10:10');
      expect(slot.status, SlotStatus.changed);
      // linked still holds
      expect(slot.actual!.linkedPlanId, planned.id);
    });

    test('complete planned writes linkedPlanId', () async {
      const date = '2026-07-06';
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '10:00',
        endTime: '11:00',
        content: '背单词',
      );
      await repository.completePlannedAsActual(date, planned);

      final snapshot = await repository.load(date);
      expect(snapshot.actualBlocks, hasLength(1));
      expect(snapshot.actualBlocks.single.linkedPlanId, planned.id);
    });

    test('clear actual for plan prefers linkedPlanId', () async {
      const date = '2026-07-06';
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '11:00',
        endTime: '12:00',
        content: '运动',
      );
      await repository.ensureActualSlot(date, planned);

      // change time so time match would fail
      var actual = (await repository.load(date)).actualBlocks.single;
      await repository.updateBlock(actual.copyWith(startTime: '11:30', endTime: '12:30'));

      // clear should still find via link
      await repository.clearActualForPlan(date, planned);

      final snapshot = await repository.load(date);
      expect(snapshot.actualBlocks.where((b) => b.content == '运动'), isEmpty);
      expect(snapshot.comparisonSlots.single.actual, isNull);
    });

    test('legacy exact-time fallback still works', () async {
      const date = '2026-07-06';
      await repository.createPlannedBlock(
        date: date,
        startTime: '13:00',
        endTime: '14:00',
        content: 'legacy',
      );

      // insert legacy actual WITHOUT linkedPlanId (simulate old data)
      // (planned var intentionally not captured to simulate legacy)
      await db.into(db.timeBlocks).insert(
        TimeBlocksCompanion.insert(
          journalDate: date,
          startTime: '13:00',
          endTime: '14:00',
          content: const Value('legacy'),
          source: 'actual',
          // no linkedPlanId -> null
          sortOrder: const Value(0),
        ),
      );

      final snapshot = await repository.load(date);
      expect(snapshot.comparisonSlots, hasLength(1));
      final slot = snapshot.comparisonSlots.single;
      expect(slot.planned, isNotNull);
      expect(slot.actual, isNotNull);
      expect(slot.actual!.linkedPlanId, isNull); // legacy
      expect(slot.status, SlotStatus.match);
    });

    test('time-only change is changed status', () async {
      const date = '2026-07-06';
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '15:00',
        endTime: '16:00',
        content: 'same content',
      );
      var ensured = await repository.ensureActualSlot(date, planned);
      await repository.updateBlock(ensured.copyWith(content: 'same content'));

      var actual = (await repository.load(date)).actualBlocks.single;
      await repository.updateBlock(actual.copyWith(
        startTime: '15:05',
        endTime: '16:05',
        // content unchanged
      ));

      final snapshot = await repository.load(date);
      final slot = snapshot.comparisonSlots.single;
      expect(slot.status, SlotStatus.changed);
      expect(slot.actual!.content.trim(), 'same content');
    });

    test('completePlannedAsActual resets changed actual time back to planned time', () async {
      const date = '2026-07-06';
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '09:00',
        endTime: '10:00',
        content: '学习',
      );
      await repository.completePlannedAsActual(date, planned);

      // simulate change: edit time and content
      var actual = (await repository.load(date)).actualBlocks.single;
      await repository.updateBlock(actual.copyWith(
        startTime: '09:15',
        endTime: '10:15',
        content: '学习（有变）',
      ));

      // now "标为按计划"
      await repository.completePlannedAsActual(date, planned);

      final snapshot = await repository.load(date);
      expect(snapshot.comparisonSlots, hasLength(1));
      final slot = snapshot.comparisonSlots.single;
      expect(slot.actual, isNotNull);
      expect(slot.actual!.startTime, planned.startTime);
      expect(slot.actual!.endTime, planned.endTime);
      expect(slot.actual!.content.trim(), '学习');
      expect(slot.status, SlotStatus.match);
      expect(slot.actual!.linkedPlanId, planned.id);
    });

    test('legacy actual edited through ensureActualSlot gets linked before time change', () async {
      const date = '2026-07-06';
      final planned = await repository.createPlannedBlock(
        date: date,
        startTime: '11:00',
        endTime: '12:00',
        content: '复习',
      );

      // insert legacy actual (no linkedPlanId, exact time)
      await db.into(db.timeBlocks).insert(
        TimeBlocksCompanion.insert(
          journalDate: date,
          startTime: '11:00',
          endTime: '12:00',
          content: const Value('复习'),
          source: 'actual',
          sortOrder: const Value(0),
        ),
      );

      // call ensureActualSlot -> should backfill link (even though time not yet changed here)
      final ensured = await repository.ensureActualSlot(date, planned);
      expect(ensured.linkedPlanId, planned.id);

      // now change time on the (now linked) actual
      await repository.updateBlock(ensured.copyWith(
        startTime: '11:10',
        endTime: '12:10',
      ));

      final snapshot = await repository.load(date);
      expect(snapshot.comparisonSlots, hasLength(1));
      final slot = snapshot.comparisonSlots.single;
      expect(slot.planned, isNotNull);
      expect(slot.actual, isNotNull);
      expect(slot.actual!.linkedPlanId, planned.id);
      expect(slot.actual!.startTime, '11:10');
      expect(slot.status, SlotStatus.changed);
    });

    test('linked actual is not reused by another plan through legacy fallback', () async {
      const date = '2026-07-06';
      final planA = await repository.createPlannedBlock(
        date: date,
        startTime: '09:00',
        endTime: '10:00',
        content: 'Plan A',
      );
      final planB = await repository.createPlannedBlock(
        date: date,
        startTime: '09:00',
        endTime: '10:00',
        content: 'Plan B',
      );

      // actual explicitly linked to plan A
      await repository.completePlannedAsActual(date, planA);

      final snapshot = await repository.load(date);
      // plan A should have the actual
      final slotA = snapshot.comparisonSlots.firstWhere((s) => s.planned?.id == planA.id);
      expect(slotA.actual, isNotNull);
      expect(slotA.actual!.linkedPlanId, planA.id);

      // plan B (same time) must NOT reuse it via legacy fallback; should be pending
      final slotB = snapshot.comparisonSlots.firstWhere((s) => s.planned?.id == planB.id);
      expect(slotB.actual, isNull);
      expect(slotB.status, SlotStatus.pending);
    });

    test('clearActualForPlan does not delete actual linked to another plan with same time', () async {
      const date = '2026-07-06';
      final planA = await repository.createPlannedBlock(
        date: date,
        startTime: '11:00',
        endTime: '12:00',
        content: 'Plan A',
      );
      final planB = await repository.createPlannedBlock(
        date: date,
        startTime: '11:00',
        endTime: '12:00',
        content: 'Plan B',
      );

      // actual linked only to A
      await repository.completePlannedAsActual(date, planA);
      final initialSnapshot = await repository.load(date);
      final actualForA = initialSnapshot.actualBlocks.singleWhere((b) => b.linkedPlanId == planA.id);
      expect(actualForA.linkedPlanId, planA.id);

      // clear for B must not touch A's actual
      await repository.clearActualForPlan(date, planB);

      final afterClear = await repository.load(date);
      expect(afterClear.actualBlocks, hasLength(1));
      final remaining = afterClear.actualBlocks.single;
      expect(remaining.linkedPlanId, planA.id);
      expect(remaining.content.trim(), 'Plan A');

      // plan A still matched, plan B pending
      final slotA = afterClear.comparisonSlots.firstWhere((s) => s.planned?.id == planA.id);
      expect(slotA.actual, isNotNull);
      final slotB = afterClear.comparisonSlots.firstWhere((s) => s.planned?.id == planB.id);
      expect(slotB.actual, isNull);
    });
  });
}
