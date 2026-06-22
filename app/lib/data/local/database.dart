import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  DailyJournals,
  TodoItems,
  TimeBlocks,
  PomodoroSessions,
  SleepRecords,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'time_journal.db');
  }

  Future<DailyJournal?> journalForDate(String date) {
    return (select(dailyJournals)..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  Future<DailyJournal> ensureJournal(String date) async {
    final existing = await journalForDate(date);
    if (existing != null) return existing;
    final id = await into(dailyJournals).insert(DailyJournalsCompanion.insert(date: date));
    return (select(dailyJournals)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<TodoItem>> todosForDate(String date) {
    return (select(todoItems)
          ..where((t) => t.journalDate.equals(date))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<List<TimeBlock>> blocksForDate(String date, String source) {
    return (select(timeBlocks)
          ..where((t) => t.journalDate.equals(date) & t.source.equals(source))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> upsertTodo(TodoItemsCompanion item) => into(todoItems).insertOnConflictUpdate(item);
  Future<void> upsertTimeBlock(TimeBlocksCompanion block) => into(timeBlocks).insertOnConflictUpdate(block);
  Future<void> deleteTodo(int id) => (delete(todoItems)..where((t) => t.id.equals(id))).go();
  Future<void> deleteTimeBlock(int id) => (delete(timeBlocks)..where((t) => t.id.equals(id))).go();

  Future<void> updateJournalNotes(String date, String notes) async {
    await ensureJournal(date);
    await (update(dailyJournals)..where((t) => t.date.equals(date))).write(
      DailyJournalsCompanion(notes: Value(notes), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> updateAvailableStudyMinutes(String date, int? minutes) async {
    await ensureJournal(date);
    await (update(dailyJournals)..where((t) => t.date.equals(date))).write(
      DailyJournalsCompanion(availableStudyMinutes: Value(minutes), updatedAt: Value(DateTime.now())),
    );
  }

  Future<SleepRecord?> sleepForDate(String date) {
    return (select(sleepRecords)..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  Future<SleepRecord> ensureSleepRecord(String date) async {
    final existing = await sleepForDate(date);
    if (existing != null) return existing;
    final id = await into(sleepRecords).insert(SleepRecordsCompanion.insert(date: date));
    return (select(sleepRecords)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> upsertSleepRecord(SleepRecordsCompanion record) => into(sleepRecords).insertOnConflictUpdate(record);

  Future<List<PomodoroSession>> sessionsForDate(String date) {
    return (select(pomodoroSessions)
          ..where((t) => t.date.equals(date))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Future<int> insertPomodoroSession(PomodoroSessionsCompanion session) => into(pomodoroSessions).insert(session);

  Future<void> updatePomodoroSession(int id, PomodoroSessionsCompanion session) {
    return (update(pomodoroSessions)..where((t) => t.id.equals(id))).write(session);
  }
}
