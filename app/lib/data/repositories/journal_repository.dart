import 'package:drift/drift.dart';
import '../local/database.dart';

class JournalSnapshot {
  JournalSnapshot({
    required this.date,
    required this.journal,
    required this.todos,
    required this.plannedBlocks,
    required this.actualBlocks,
  });

  final String date;
  final DailyJournal journal;
  final List<TodoItem> todos;
  final List<TimeBlock> plannedBlocks;
  final List<TimeBlock> actualBlocks;

  int get plannedMinutes => _sumMinutes(plannedBlocks);
  int get actualMinutes => _sumMinutes(actualBlocks);

  static int _sumMinutes(List<TimeBlock> blocks) {
    var total = 0;
    for (final b in blocks) {
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
    return JournalSnapshot(
      date: date,
      journal: journal,
      todos: todos,
      plannedBlocks: planned,
      actualBlocks: actual,
    );
  }

  Future<void> saveNotes(String date, String notes) => _db.updateJournalNotes(date, notes);

  Future<void> saveAvailableMinutes(String date, int? minutes) =>
      _db.updateAvailableStudyMinutes(date, minutes);

  Future<TodoItem> addTodo(String date) async {
    final existing = await _db.todosForDate(date);
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    final id = await _db.into(_db.todoItems).insert(
      TodoItemsCompanion.insert(journalDate: date, sortOrder: Value(order)),
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
  }) async {
    final existing = await _db.blocksForDate(date, 'actual');
    final order = existing.isEmpty ? 0 : existing.last.sortOrder + 1;
    await _db.into(_db.timeBlocks).insert(
      TimeBlocksCompanion.insert(
        journalDate: date,
        startTime: startTime,
        endTime: endTime,
        content: Value(content),
        source: 'actual',
        sortOrder: Value(order),
      ),
    );
  }
}
