import 'package:drift/drift.dart';
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
      final aStart = _parse((a.planned ?? a.actual)!.startTime);
      final bStart = _parse((b.planned ?? b.actual)!.startTime);
      return aStart.compareTo(bStart);
    });
    return slots;
  }

  static TimeBlock? _matchActual(TimeBlock planned, List<TimeBlock> actualBlocks) {
    for (final a in actualBlocks) {
      if (a.startTime == planned.startTime && a.endTime == planned.endTime) {
        return a;
      }
    }
    return null;
  }

  static int _sumMinutes(List<TimeBlock> blocks) {
    var total = 0;
    for (final b in blocks) {
      if (b.content.trim().isEmpty) continue;
      final start = _parse(b.startTime);
      final end = _parse(b.endTime);
      if (end > start) total += end - start;
    }
    return total;
  }

  static int _parse(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }
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
    final focusMinutes =
        completed.fold<int>(0, (sum, s) => sum + (s.actualSeconds ~/ 60));
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

  Future<void> reorderTodos(String date, int oldIndex, int newIndex) async {
    final todos = List<TodoItem>.from(await _db.todosForDate(date));
    if (oldIndex < 0 ||
        oldIndex >= todos.length ||
        newIndex < 0 ||
        newIndex >= todos.length) {
      return;
    }
    final moved = todos.removeAt(oldIndex);
    todos.insert(newIndex, moved);
    for (var i = 0; i < todos.length; i++) {
      await updateTodo(todos[i].copyWith(sortOrder: i));
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
      sortOrder: Value(block.sortOrder),
    ));
  }

  Future<void> removeBlock(int id) => _db.deleteTimeBlock(id);

  Future<void> completePlannedAsActual(String date, TimeBlock planned) async {
    final actualBlocks = await _db.blocksForDate(date, 'actual');
    final existing = JournalSnapshot._matchActual(planned, actualBlocks);
    if (existing != null) {
      await updateBlock(existing.copyWith(
        content: planned.content,
        linkedTodoId: Value(planned.linkedTodoId),
      ));
      return;
    }
    final order = actualBlocks.isEmpty ? 0 : actualBlocks.last.sortOrder + 1;
    await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: planned.startTime,
        endTime: planned.endTime,
        content: Value(planned.content),
        source: 'actual',
        linkedTodoId: Value(planned.linkedTodoId),
        sortOrder: Value(order),
      ),
    );
  }

  Future<TimeBlock> ensureActualSlot(String date, TimeBlock planned) async {
    final actualBlocks = await _db.blocksForDate(date, 'actual');
    final existing = JournalSnapshot._matchActual(planned, actualBlocks);
    if (existing != null) return existing;
    final order = actualBlocks.isEmpty ? 0 : actualBlocks.last.sortOrder + 1;
    final id = await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: planned.startTime,
        endTime: planned.endTime,
        source: 'actual',
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
    final existing = JournalSnapshot._matchActual(planned, actualBlocks);
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

  Future<void> copyPlannedToActual(String date) async {
    final planned = await _db.blocksForDate(date, 'planned');
    final actual = await _db.blocksForDate(date, 'actual');
    var order = actual.isEmpty ? 0 : actual.last.sortOrder + 1;
    for (final block in planned) {
      await _db.into(_db.timeBlocks).insert(
        TimeBlocksCompanion.insert(
          journalDate: date,
          startTime: block.startTime,
          endTime: block.endTime,
          content: Value(block.content),
          source: 'actual',
          linkedTodoId: Value(block.linkedTodoId),
          sortOrder: Value(order++),
        ),
      );
    }
  }

  Future<void> addActualFromPomodoro({
    required String date,
    required String startTime,
    required String endTime,
    required String content,
    int? linkedTodoId,
  }) async {
    final existing = await _db.blocksForDate(date, 'actual');

    // 去重：按时间段 + linkedTodoId + content 匹配已有 actual 块
    for (final block in existing) {
      if (block.startTime == startTime &&
          block.endTime == endTime &&
          block.linkedTodoId == linkedTodoId &&
          block.content.trim() == content.trim()) {
        return; // 完全匹配，跳过
      }
    }

    // 时间段相同但 content 有变化 → 更新已有行
    for (final block in existing) {
      if (block.startTime == startTime &&
          block.endTime == endTime &&
          block.linkedTodoId == linkedTodoId) {
        await updateBlock(block.copyWith(content: content));
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
        sortOrder: Value(order),
      ),
    );
  }
}
