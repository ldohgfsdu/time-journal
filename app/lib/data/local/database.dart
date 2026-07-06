import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    DailyJournals,
    TodoItems,
    TimeBlocks,
    PomodoroSessions,
    SleepRecords,
    WeeklyReflections,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(weeklyReflections);
      }
      if (from < 3) {
        await migrator.addColumn(timeBlocks, timeBlocks.linkedPlanId);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'time_journal.db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  Future<DailyJournal?> journalForDate(String date) {
    return (select(
      dailyJournals,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  Future<DailyJournal> ensureJournal(String date) async {
    final existing = await journalForDate(date);
    if (existing != null) return existing;
    final id = await into(
      dailyJournals,
    ).insert(DailyJournalsCompanion.insert(date: date));
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

  Future<void> upsertTodo(TodoItemsCompanion item) =>
      into(todoItems).insertOnConflictUpdate(item);
  Future<void> upsertTimeBlock(TimeBlocksCompanion block) =>
      into(timeBlocks).insertOnConflictUpdate(block);
  Future<void> deleteTodo(int id) =>
      (delete(todoItems)..where((t) => t.id.equals(id))).go();
  Future<void> deleteTimeBlock(int id) =>
      (delete(timeBlocks)..where((t) => t.id.equals(id))).go();

  Future<void> updateJournalNotes(String date, String notes) async {
    await ensureJournal(date);
    await (update(dailyJournals)..where((t) => t.date.equals(date))).write(
      DailyJournalsCompanion(
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateAvailableStudyMinutes(String date, int? minutes) async {
    await ensureJournal(date);
    await (update(dailyJournals)..where((t) => t.date.equals(date))).write(
      DailyJournalsCompanion(
        availableStudyMinutes: Value(minutes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<SleepRecord?> sleepForDate(String date) {
    return (select(
      sleepRecords,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  Future<SleepRecord> ensureSleepRecord(String date) async {
    final existing = await sleepForDate(date);
    if (existing != null) return existing;
    final id = await into(
      sleepRecords,
    ).insert(SleepRecordsCompanion.insert(date: date));
    return (select(sleepRecords)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> upsertSleepRecord(SleepRecordsCompanion record) async {
    if (!record.date.present) {
      await into(sleepRecords).insert(record);
      return;
    }
    final date = record.date.value;
    final existing = await sleepForDate(date);
    if (existing != null) {
      await (update(sleepRecords)
            ..where((t) => t.id.equals(existing.id)))
          .write(record);
      return;
    }
    await into(sleepRecords).insert(record);
  }

  Future<List<PomodoroSession>> sessionsForDate(String date) {
    return (select(pomodoroSessions)
          ..where((t) => t.date.equals(date))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Future<List<PomodoroSession>> recentSessions({int limit = 5}) {
    return (select(pomodoroSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit, offset: 0))
        .get();
  }

  Future<int> insertPomodoroSession(PomodoroSessionsCompanion session) =>
      into(pomodoroSessions).insert(session);

  Future<void> updatePomodoroSession(
    int id,
    PomodoroSessionsCompanion session,
  ) {
    return (update(
      pomodoroSessions,
    )..where((t) => t.id.equals(id))).write(session);
  }

  Future<WeeklyReflection?> reflectionForWeek(String weekMonday) {
    return (select(
      weeklyReflections,
    )..where((t) => t.weekMonday.equals(weekMonday))).getSingleOrNull();
  }

  Future<void> upsertWeeklyReflection(String weekMonday, String note) async {
    final existing = await reflectionForWeek(weekMonday);
    if (existing != null) {
      await (update(weeklyReflections)
            ..where((t) => t.id.equals(existing.id)))
          .write(WeeklyReflectionsCompanion(
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ));
      return;
    }
    await into(weeklyReflections).insert(
      WeeklyReflectionsCompanion.insert(
        weekMonday: weekMonday,
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(weeklyReflections).go();
      await delete(pomodoroSessions).go();
      await delete(timeBlocks).go();
      await delete(todoItems).go();
      await delete(dailyJournals).go();
      await delete(sleepRecords).go();
    });
  }
}
