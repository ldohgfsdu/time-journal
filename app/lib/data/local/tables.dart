import 'package:drift/drift.dart';

class DailyJournals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().unique()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get availableStudyMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get journalDate => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class TimeBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get journalDate => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get source => text()();
  IntColumn get linkedTodoId => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  IntColumn get durationMinutes => integer()();
  IntColumn get actualSeconds => integer().withDefault(const Constant(0))();
  IntColumn get interruptCount => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get linkedTodoId => integer().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
}

class SleepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().unique()();
  TextColumn get targetBedtime => text().withDefault(const Constant('23:00'))();
  TextColumn get targetWakeTime => text().withDefault(const Constant('07:00'))();
  DateTimeColumn get actualBedtime => dateTime().nullable()();
  DateTimeColumn get actualWakeTime => dateTime().nullable()();
  IntColumn get sleepScore => integer().withDefault(const Constant(0))();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  IntColumn get totalScore => integer().withDefault(const Constant(0))();
}
