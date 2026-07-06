import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/core/utils/todo_reorder.dart';
import 'package:time_journal/data/local/database.dart';

TodoItem _todo(int id, {int sortOrder = 0}) => TodoItem(
      id: id,
      journalDate: '2026-07-04',
      content: 'todo-$id',
      priority: 0,
      completed: false,
      sortOrder: sortOrder,
    );

void main() {
  group('mapVisibleTodoReorder', () {
    test('maps reorder when visible list equals scope', () {
      final scope = [_todo(1), _todo(2), _todo(3)];

      final indices = mapVisibleTodoReorder(
        visibleTodos: scope,
        scopeTodos: scope,
        oldIndex: 0,
        newIndex: 2,
      );

      expect(indices, isNotNull);
      expect(indices!.oldIndex, 0);
      expect(indices.newIndex, 2);
    });

    test('maps reorder within collapsed visible subset', () {
      final scope = [
        _todo(1, sortOrder: 0),
        _todo(2, sortOrder: 1),
        _todo(3, sortOrder: 2),
        _todo(4, sortOrder: 3),
        _todo(5, sortOrder: 4),
        _todo(6, sortOrder: 5),
      ];
      final visible = scope.take(5).toList();

      final indices = mapVisibleTodoReorder(
        visibleTodos: visible,
        scopeTodos: scope,
        oldIndex: 4,
        newIndex: 0,
      );

      expect(indices, isNotNull);
      expect(indices!.oldIndex, 4);
      expect(indices.newIndex, 0);
    });

    test('maps move to end within visible subset', () {
      final scope = [
        _todo(1, sortOrder: 0),
        _todo(2, sortOrder: 1),
        _todo(3, sortOrder: 2),
        _todo(4, sortOrder: 3),
        _todo(5, sortOrder: 4),
        _todo(6, sortOrder: 5),
      ];
      final visible = scope.take(5).toList();

      final indices = mapVisibleTodoReorder(
        visibleTodos: visible,
        scopeTodos: scope,
        oldIndex: 0,
        newIndex: 4,
      );

      expect(indices, isNotNull);
      expect(indices!.oldIndex, 0);
      expect(indices.newIndex, 4);
    });

    test('returns null for out-of-range indices', () {
      final scope = [_todo(1), _todo(2)];

      expect(
        mapVisibleTodoReorder(
          visibleTodos: scope,
          scopeTodos: scope,
          oldIndex: 5,
          newIndex: 0,
        ),
        isNull,
      );
    });
  });
}