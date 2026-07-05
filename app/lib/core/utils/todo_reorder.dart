import '../../data/local/database.dart';

class TodoReorderIndices {
  const TodoReorderIndices({required this.oldIndex, required this.newIndex});

  final int oldIndex;
  final int newIndex;
}

/// Maps a drag within [visibleTodos] to indices within [scopeTodos].
///
/// [newIndex] must follow [ReorderableListView] `onReorderItem` semantics
/// (already adjusted for the removed item).
TodoReorderIndices? mapVisibleTodoReorder({
  required List<TodoItem> visibleTodos,
  required List<TodoItem> scopeTodos,
  required int oldIndex,
  required int newIndex,
}) {
  if (visibleTodos.isEmpty || scopeTodos.isEmpty) return null;
  if (oldIndex < 0 || oldIndex >= visibleTodos.length) return null;
  if (newIndex < 0 || newIndex > visibleTodos.length) return null;

  final movedId = visibleTodos[oldIndex].id;
  final scopeOldIndex = scopeTodos.indexWhere((t) => t.id == movedId);
  if (scopeOldIndex < 0) return null;

  final reorderedVisible = List<TodoItem>.from(visibleTodos);
  final moved = reorderedVisible.removeAt(oldIndex);
  reorderedVisible.insert(newIndex, moved);

  final int scopeNewIndex;
  if (newIndex == 0) {
    scopeNewIndex = 0;
  } else {
    final beforeId = reorderedVisible[newIndex - 1].id;
    final anchorIndex = scopeTodos.indexWhere((t) => t.id == beforeId);
    if (anchorIndex < 0) return null;
    var targetIndex = anchorIndex + 1;
    if (scopeOldIndex < targetIndex) {
      targetIndex--;
    }
    scopeNewIndex = targetIndex;
  }

  return TodoReorderIndices(oldIndex: scopeOldIndex, newIndex: scopeNewIndex);
}