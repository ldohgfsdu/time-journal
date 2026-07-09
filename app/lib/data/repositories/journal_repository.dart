import 'package:drift/drift.dart';
import '../../core/utils/time_utils.dart';
import '../local/database.dart';
import '../models/comparison_slot.dart';

class JournalSnapshot {
  JournalSnapshot({
    required this.date,
    required this.journal,
    required this.todos,
    required this.plannedBlocks,
    required this.actualBlocks,
    this.focusMinutes = 0,
    this.focusSessions = 0,
  });

  final String date;
  final DailyJournal journal;
  final List<TodoItem> todos;
  final List<TimeBlock> plannedBlocks;
  final List<TimeBlock> actualBlocks;
  final int focusMinutes;
  final int focusSessions;

  int get plannedMinutes => _sumMinutes(plannedBlocks);
  int get actualMinutes => _sumMinutes(actualBlocks);

  int get plannedSegmentCount =>
      plannedBlocks.where((b) => b.content.trim().isNotEmpty).length;

  int get actualSegmentCount =>
      actualBlocks.where((b) => b.content.trim().isNotEmpty).length;

  List<ComparisonSlot> get comparisonSlots {
    final matchedActualIds = <int>{};
    final slots = <ComparisonSlot>[];

    for (final plan in plannedBlocks) {
      if (plan.content.trim().isEmpty) continue;
      final actual = _matchActual(plan, actualBlocks);
      if (actual != null) matchedActualIds.add(actual.id);
      slots.add(ComparisonSlot(planned: plan, actual: actual));
    }

    for (final actual in actualBlocks) {
      if (actual.content.trim().isEmpty) continue;
      if (matchedActualIds.contains(actual.id)) continue;
      slots.add(ComparisonSlot(actual: actual, orphanActual: true));
    }

    slots.sort((a, b) {
      final aStart = parseTime(a.planned?.startTime ?? a.actual?.startTime ?? '00:00');
      final bStart = parseTime(b.planned?.startTime ?? b.actual?.startTime ?? '00:00');
      return aStart.compareTo(bStart);
    });
    return slots;
  }

  static TimeBlock? _matchActual(TimeBlock planned, List<TimeBlock> actualBlocks) {
    // 1. explicit link (P0-6)
    for (final a in actualBlocks) {
      if (a.linkedPlanId == planned.id) {
        return a;
      }
    }
    // 2. legacy exact-time fallback ONLY for unlinked actuals (linkedPlanId == null)
    //    explicit link > unlinked legacy; already-linked actuals must not be reused by time match
    for (final a in actualBlocks) {
      if (a.linkedPlanId != null) continue;
      if (a.startTime == planned.startTime && a.endTime == planned.endTime) {
        return a;
      }
    }
    return null;
  }

  static int _sumMinutes(List<TimeBlock> blocks) => sumBlockMinutes(blocks);
}

class JournalRepository {
  JournalRepository(this._db);
  final AppDatabase _db;

  Future<JournalSnapshot> load(String date) async {
    final journal = await _db.ensureJournal(date);
    final todos = await _db.todosForDate(date);
    final planned = await _db.blocksForDate(date, 'planned');
    final actual = await _db.blocksForDate(date, 'actual');
    final sessions = await _db.sessionsForDate(date);
    final completed = sessions.where((s) => s.completed).toList();
    // 与番茄记入一致：不足 1 分钟也按 1 分钟计，避免 59 秒显示 0
    final focusMinutes = completed.fold<int>(0, (sum, s) {
      final m = (s.actualSeconds / 60).round();
      if (s.actualSeconds > 0 && m < 1) return sum + 1;
      return sum + m.clamp(0, 999);
    });
    return JournalSnapshot(
      date: date,
      journal: journal,
      todos: todos,
      plannedBlocks: planned,
      actualBlocks: actual,
      focusMinutes: focusMinutes,
      focusSessions: completed.length,
    );
  }

  Future<void> purgeEmptyRecords(String date) async {
    final rawTodos = await _db.todosForDate(date);
    for (final todo in rawTodos) {
      if (todo.content.trim().isEmpty) {
        await removeTodo(todo.id);
      }
    }
    var planned = await _db.blocksForDate(date, 'planned');
    var actual = await _db.blocksForDate(date, 'actual');
    for (final block in [...planned, ...actual]) {
      if (block.content.trim().isEmpty) {
        await removeBlock(block.id);
      }
    }
  }

  Future<void> saveNotes(String date, String notes) => _db.updateJournalNotes(date, notes);

  Future<void> saveAvailableMinutes(String date, int? minutes) =>
      _db.updateAvailableStudyMinutes(date, minutes);

  Future<bool> hasAnyTodoContent() async {
    final rows = await (_db.select(_db.todoItems)
          ..where((t) => t.content.equals('').not()))
        .get();
    return rows.isNotEmpty;
  }

  Future<TodoItem> createTodo(String date, String content) async {
    final existing = await _db.todosForDate(date);
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final id = await _db.into(_db.todoItems).insert(
      TodoItemsCompanion.insert(
        journalDate: date,
        content: Value(content.trim()),
        sortOrder: Value(order),
      ),
    );
    return (_db.select(_db.todoItems)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateTodo(TodoItem item) {
    return _db.upsertTodo(TodoItemsCompanion(
      id: Value(item.id),
      journalDate: Value(item.journalDate),
      content: Value(item.content),
      priority: Value(item.priority),
      completed: Value(item.completed),
      sortOrder: Value(item.sortOrder),
    ));
  }

  Future<void> removeTodo(int id) => _db.deleteTodo(id);

  Future<void> reorderTodos(
    String date,
    int oldIndex,
    int newIndex, {
    List<int>? scopedTodoIds,
  }) async {
    var allTodos = List<TodoItem>.from(await _db.todosForDate(date));

    if (scopedTodoIds != null) {
      final scopeIdSet = scopedTodoIds.toSet();
      final scopedTodos = <TodoItem>[
        for (final id in scopedTodoIds)
          ...allTodos.where((todo) => todo.id == id),
      ];

      if (oldIndex < 0 ||
          oldIndex >= scopedTodos.length ||
          newIndex < 0 ||
          newIndex >= scopedTodos.length) {
        return;
      }

      final moved = scopedTodos.removeAt(oldIndex);
      scopedTodos.insert(newIndex, moved);

      var scopedCursor = 0;
      allTodos = [
        for (final todo in allTodos)
          if (scopeIdSet.contains(todo.id))
            scopedTodos[scopedCursor++]
          else
            todo,
      ];
    } else {
      if (oldIndex < 0 ||
          oldIndex >= allTodos.length ||
          newIndex < 0 ||
          newIndex >= allTodos.length) {
        return;
      }
      final moved = allTodos.removeAt(oldIndex);
      allTodos.insert(newIndex, moved);
    }

    for (var i = 0; i < allTodos.length; i++) {
      await updateTodo(allTodos[i].copyWith(sortOrder: i));
    }
  }

  Future<TimeBlock> addBlock(String date, String source) async {
    final existing = await _db.blocksForDate(date, source);
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final id = await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: '09:00',
        endTime: '10:00',
        source: source,
        sortOrder: Value(order),
      ),
    );
    return (_db.select(_db.timeBlocks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateBlock(TimeBlock block) {
    return _db.upsertTimeBlock(TimeBlocksCompanion(
      id: Value(block.id),
      journalDate: Value(block.journalDate),
      startTime: Value(block.startTime),
      endTime: Value(block.endTime),
      content: Value(block.content),
      source: Value(block.source),
      linkedTodoId: Value(block.linkedTodoId),
      linkedPlanId: Value(block.linkedPlanId),
      sortOrder: Value(block.sortOrder),
    ));
  }

  Future<void> removeBlock(int id) => _db.deleteTimeBlock(id);

  Future<String?> todoContentById(int todoId) async {
    final row = await (_db.select(_db.todoItems)
          ..where((t) => t.id.equals(todoId)))
        .getSingleOrNull();
    final text = row?.content.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  /// Resolve planned block for a focus session (planId first, then same-day todo).
  Future<TimeBlock?> findPlannedForFocus({
    required String date,
    int? linkedPlanId,
    int? linkedTodoId,
  }) async {
    final planned = await _db.blocksForDate(date, 'planned');
    if (linkedPlanId != null) {
      for (final p in planned) {
        if (p.id == linkedPlanId && p.content.trim().isNotEmpty) return p;
      }
    }
    if (linkedTodoId != null) {
      for (final p in planned) {
        if (p.linkedTodoId == linkedTodoId && p.content.trim().isNotEmpty) {
          return p;
        }
      }
    }
    return null;
  }

  Future<void> completePlannedAsActual(
    String date,
    TimeBlock planned, {
    String? note,
  }) async {
    final base = planned.content.trim();
    final trimmedNote = note?.trim();
    final content = (trimmedNote != null && trimmedNote.isNotEmpty)
        ? '$base（$trimmedNote）'
        : base;
    final actualBlocks = await _db.blocksForDate(date, 'actual');
    final existing = JournalSnapshot._matchActual(planned, actualBlocks);
    if (existing != null) {
      await updateBlock(existing.copyWith(
        startTime: planned.startTime,
        endTime: planned.endTime,
        content: content,
        linkedTodoId: Value(planned.linkedTodoId),
        linkedPlanId: Value<int?>(planned.id),
      ));
      return;
    }
    final order = actualBlocks.isEmpty ? 0 : actualBlocks.last.sortOrder + 1;
    await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: planned.startTime,
        endTime: planned.endTime,
        content: Value(content),
        source: 'actual',
        linkedTodoId: Value(planned.linkedTodoId),
        linkedPlanId: Value<int?>(planned.id),
        sortOrder: Value(order),
      ),
    );
  }

  Future<TimeBlock> ensureActualSlot(String date, TimeBlock planned) async {
    final actualBlocks = await _db.blocksForDate(date, 'actual');
    final existing = JournalSnapshot._matchActual(planned, actualBlocks);
    if (existing != null) {
      // backfill link for legacy exact-time match (or mismatched link)
      if (existing.linkedPlanId == null || existing.linkedPlanId != planned.id) {
        final updated = existing.copyWith(
          linkedPlanId: Value<int?>(planned.id),
        );
        await updateBlock(updated);
        return updated;
      }
      return existing;
    }
    final order = actualBlocks.isEmpty ? 0 : actualBlocks.last.sortOrder + 1;
    final id = await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: planned.startTime,
        endTime: planned.endTime,
        source: 'actual',
        linkedPlanId: Value<int?>(planned.id),
        sortOrder: Value(order),
      ),
    );
    return (_db.select(_db.timeBlocks)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<TimeBlock> createPlannedBlock({
    required String date,
    required String startTime,
    required String endTime,
    required String content,
    int? linkedTodoId,
  }) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('计划内容不能为空');
    }
    final existing = await _db.blocksForDate(date, 'planned');
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final id = await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: startTime,
        endTime: endTime,
        content: Value(content.trim()),
        source: 'planned',
        linkedTodoId: Value(linkedTodoId),
        sortOrder: Value(order),
      ),
    );
    return (_db.select(_db.timeBlocks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<TimeBlock> createCatchUpActual({
    required String date,
    required String startTime,
    required String endTime,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('补记内容不能为空');
    }
    final existing = await _db.blocksForDate(date, 'actual');
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final id = await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: startTime,
        endTime: endTime,
        content: Value(content.trim()),
        source: 'actual',
        sortOrder: Value(order),
      ),
    );
    return (_db.select(_db.timeBlocks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> clearActualForPlan(String date, TimeBlock planned) async {
    final actualBlocks = await _db.blocksForDate(date, 'actual');
    // prefer linkedPlanId for clear (P0-6), fallback to match
    TimeBlock? existing;
    for (final a in actualBlocks) {
      if (a.linkedPlanId == planned.id) {
        existing = a;
        break;
      }
    }
    existing ??= JournalSnapshot._matchActual(planned, actualBlocks);
    if (existing != null) {
      await removeBlock(existing.id);
    }
  }

  Future<TimeBlock> addBlockWithTimes(
    String date,
    String source,
    String start,
    String end,
  ) async {
    final existing = await _db.blocksForDate(date, source);
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final id = await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: start,
        endTime: end,
        source: source,
        sortOrder: Value(order),
      ),
    );
    return (_db.select(_db.timeBlocks)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> addActualFromPomodoro({
    required String date,
    required String startTime,
    required String endTime,
    required String content,
    int? linkedTodoId,
    int? linkedPlanId,
  }) async {
    final existing = await _db.blocksForDate(date, 'actual');

    // 优先使用直接传入的 linkedPlanId（来自 planned block 选择），
    // 否则若有 linkedTodoId 则查询同日同 linkedTodoId 的 planned 进行回填。
    // 这样支持从 todo 选择（PR#7 路径）和从 planned 直接选择。
    int? effectivePlanId = linkedPlanId;
    if (effectivePlanId == null && linkedTodoId != null) {
      final planned = await _db.blocksForDate(date, 'planned');
      for (final p in planned) {
        if (p.linkedTodoId == linkedTodoId) {
          effectivePlanId = p.id;
          break;
        }
      }
    }

    // 去重：按时间段 + linkedTodoId + content 匹配已有 actual 块
    // 即使去重命中，也要 backfill linkedPlanId（避免已有 orphan 残留）
    for (final block in existing) {
      if (block.startTime == startTime &&
          block.endTime == endTime &&
          block.linkedTodoId == linkedTodoId &&
          block.content.trim() == content.trim()) {
        if (effectivePlanId != null && block.linkedPlanId != effectivePlanId) {
          await updateBlock(block.copyWith(linkedPlanId: Value(effectivePlanId)));
        }
        return; // 完全匹配，跳过
      }
    }

    // 时间段相同但 content 有变化 → 更新已有行
    // 只有本次有 effectivePlanId 时才设置，否则使用 absent 保留原值
    // 避免已有关联的 actual 被意外 detach
    for (final block in existing) {
      if (block.startTime == startTime &&
          block.endTime == endTime &&
          block.linkedTodoId == linkedTodoId) {
        await updateBlock(block.copyWith(
          content: content,
          linkedPlanId: effectivePlanId != null
              ? Value<int?>(effectivePlanId)
              : const Value<int?>.absent(),
        ));
        return;
      }
    }

    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: startTime,
        endTime: endTime,
        content: Value(content),
        source: 'actual',
        linkedTodoId: Value(linkedTodoId),
        linkedPlanId: Value(effectivePlanId),
        sortOrder: Value(order),
      ),
    );
  }
}
