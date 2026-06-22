// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DailyJournalsTable extends DailyJournals
    with TableInfo<$DailyJournalsTable, DailyJournal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyJournalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _availableStudyMinutesMeta =
      const VerificationMeta('availableStudyMinutes');
  @override
  late final GeneratedColumn<int> availableStudyMinutes = GeneratedColumn<int>(
    'available_study_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    notes,
    availableStudyMinutes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_journals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyJournal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('available_study_minutes')) {
      context.handle(
        _availableStudyMinutesMeta,
        availableStudyMinutes.isAcceptableOrUnknown(
          data['available_study_minutes']!,
          _availableStudyMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyJournal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyJournal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      availableStudyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_study_minutes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyJournalsTable createAlias(String alias) {
    return $DailyJournalsTable(attachedDatabase, alias);
  }
}

class DailyJournal extends DataClass implements Insertable<DailyJournal> {
  final int id;
  final String date;
  final String notes;
  final int? availableStudyMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyJournal({
    required this.id,
    required this.date,
    required this.notes,
    this.availableStudyMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || availableStudyMinutes != null) {
      map['available_study_minutes'] = Variable<int>(availableStudyMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyJournalsCompanion toCompanion(bool nullToAbsent) {
    return DailyJournalsCompanion(
      id: Value(id),
      date: Value(date),
      notes: Value(notes),
      availableStudyMinutes: availableStudyMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(availableStudyMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyJournal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyJournal(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      notes: serializer.fromJson<String>(json['notes']),
      availableStudyMinutes: serializer.fromJson<int?>(
        json['availableStudyMinutes'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'notes': serializer.toJson<String>(notes),
      'availableStudyMinutes': serializer.toJson<int?>(availableStudyMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyJournal copyWith({
    int? id,
    String? date,
    String? notes,
    Value<int?> availableStudyMinutes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyJournal(
    id: id ?? this.id,
    date: date ?? this.date,
    notes: notes ?? this.notes,
    availableStudyMinutes: availableStudyMinutes.present
        ? availableStudyMinutes.value
        : this.availableStudyMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyJournal copyWithCompanion(DailyJournalsCompanion data) {
    return DailyJournal(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      availableStudyMinutes: data.availableStudyMinutes.present
          ? data.availableStudyMinutes.value
          : this.availableStudyMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyJournal(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('availableStudyMinutes: $availableStudyMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, notes, availableStudyMinutes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyJournal &&
          other.id == this.id &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.availableStudyMinutes == this.availableStudyMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyJournalsCompanion extends UpdateCompanion<DailyJournal> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> notes;
  final Value<int?> availableStudyMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyJournalsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.availableStudyMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyJournalsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.notes = const Value.absent(),
    this.availableStudyMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyJournal> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? notes,
    Expression<int>? availableStudyMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (availableStudyMinutes != null)
        'available_study_minutes': availableStudyMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyJournalsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? notes,
    Value<int?>? availableStudyMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DailyJournalsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      availableStudyMinutes:
          availableStudyMinutes ?? this.availableStudyMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (availableStudyMinutes.present) {
      map['available_study_minutes'] = Variable<int>(
        availableStudyMinutes.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyJournalsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('availableStudyMinutes: $availableStudyMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TodoItemsTable extends TodoItems
    with TableInfo<$TodoItemsTable, TodoItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _journalDateMeta = const VerificationMeta(
    'journalDate',
  );
  @override
  late final GeneratedColumn<String> journalDate = GeneratedColumn<String>(
    'journal_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    journalDate,
    content,
    priority,
    completed,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('journal_date')) {
      context.handle(
        _journalDateMeta,
        journalDate.isAcceptableOrUnknown(
          data['journal_date']!,
          _journalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalDateMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      journalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_date'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TodoItemsTable createAlias(String alias) {
    return $TodoItemsTable(attachedDatabase, alias);
  }
}

class TodoItem extends DataClass implements Insertable<TodoItem> {
  final int id;
  final String journalDate;
  final String content;
  final int priority;
  final bool completed;
  final int sortOrder;
  const TodoItem({
    required this.id,
    required this.journalDate,
    required this.content,
    required this.priority,
    required this.completed,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['journal_date'] = Variable<String>(journalDate);
    map['content'] = Variable<String>(content);
    map['priority'] = Variable<int>(priority);
    map['completed'] = Variable<bool>(completed);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TodoItemsCompanion toCompanion(bool nullToAbsent) {
    return TodoItemsCompanion(
      id: Value(id),
      journalDate: Value(journalDate),
      content: Value(content),
      priority: Value(priority),
      completed: Value(completed),
      sortOrder: Value(sortOrder),
    );
  }

  factory TodoItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItem(
      id: serializer.fromJson<int>(json['id']),
      journalDate: serializer.fromJson<String>(json['journalDate']),
      content: serializer.fromJson<String>(json['content']),
      priority: serializer.fromJson<int>(json['priority']),
      completed: serializer.fromJson<bool>(json['completed']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'journalDate': serializer.toJson<String>(journalDate),
      'content': serializer.toJson<String>(content),
      'priority': serializer.toJson<int>(priority),
      'completed': serializer.toJson<bool>(completed),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TodoItem copyWith({
    int? id,
    String? journalDate,
    String? content,
    int? priority,
    bool? completed,
    int? sortOrder,
  }) => TodoItem(
    id: id ?? this.id,
    journalDate: journalDate ?? this.journalDate,
    content: content ?? this.content,
    priority: priority ?? this.priority,
    completed: completed ?? this.completed,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TodoItem copyWithCompanion(TodoItemsCompanion data) {
    return TodoItem(
      id: data.id.present ? data.id.value : this.id,
      journalDate: data.journalDate.present
          ? data.journalDate.value
          : this.journalDate,
      content: data.content.present ? data.content.value : this.content,
      priority: data.priority.present ? data.priority.value : this.priority,
      completed: data.completed.present ? data.completed.value : this.completed,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoItem(')
          ..write('id: $id, ')
          ..write('journalDate: $journalDate, ')
          ..write('content: $content, ')
          ..write('priority: $priority, ')
          ..write('completed: $completed, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, journalDate, content, priority, completed, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItem &&
          other.id == this.id &&
          other.journalDate == this.journalDate &&
          other.content == this.content &&
          other.priority == this.priority &&
          other.completed == this.completed &&
          other.sortOrder == this.sortOrder);
}

class TodoItemsCompanion extends UpdateCompanion<TodoItem> {
  final Value<int> id;
  final Value<String> journalDate;
  final Value<String> content;
  final Value<int> priority;
  final Value<bool> completed;
  final Value<int> sortOrder;
  const TodoItemsCompanion({
    this.id = const Value.absent(),
    this.journalDate = const Value.absent(),
    this.content = const Value.absent(),
    this.priority = const Value.absent(),
    this.completed = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TodoItemsCompanion.insert({
    this.id = const Value.absent(),
    required String journalDate,
    this.content = const Value.absent(),
    this.priority = const Value.absent(),
    this.completed = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : journalDate = Value(journalDate);
  static Insertable<TodoItem> custom({
    Expression<int>? id,
    Expression<String>? journalDate,
    Expression<String>? content,
    Expression<int>? priority,
    Expression<bool>? completed,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalDate != null) 'journal_date': journalDate,
      if (content != null) 'content': content,
      if (priority != null) 'priority': priority,
      if (completed != null) 'completed': completed,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TodoItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? journalDate,
    Value<String>? content,
    Value<int>? priority,
    Value<bool>? completed,
    Value<int>? sortOrder,
  }) {
    return TodoItemsCompanion(
      id: id ?? this.id,
      journalDate: journalDate ?? this.journalDate,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (journalDate.present) {
      map['journal_date'] = Variable<String>(journalDate.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemsCompanion(')
          ..write('id: $id, ')
          ..write('journalDate: $journalDate, ')
          ..write('content: $content, ')
          ..write('priority: $priority, ')
          ..write('completed: $completed, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TimeBlocksTable extends TimeBlocks
    with TableInfo<$TimeBlocksTable, TimeBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _journalDateMeta = const VerificationMeta(
    'journalDate',
  );
  @override
  late final GeneratedColumn<String> journalDate = GeneratedColumn<String>(
    'journal_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedTodoIdMeta = const VerificationMeta(
    'linkedTodoId',
  );
  @override
  late final GeneratedColumn<int> linkedTodoId = GeneratedColumn<int>(
    'linked_todo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    journalDate,
    startTime,
    endTime,
    content,
    source,
    linkedTodoId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('journal_date')) {
      context.handle(
        _journalDateMeta,
        journalDate.isAcceptableOrUnknown(
          data['journal_date']!,
          _journalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_journalDateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('linked_todo_id')) {
      context.handle(
        _linkedTodoIdMeta,
        linkedTodoId.isAcceptableOrUnknown(
          data['linked_todo_id']!,
          _linkedTodoIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeBlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      journalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      linkedTodoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_todo_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TimeBlocksTable createAlias(String alias) {
    return $TimeBlocksTable(attachedDatabase, alias);
  }
}

class TimeBlock extends DataClass implements Insertable<TimeBlock> {
  final int id;
  final String journalDate;
  final String startTime;
  final String endTime;
  final String content;
  final String source;
  final int? linkedTodoId;
  final int sortOrder;
  const TimeBlock({
    required this.id,
    required this.journalDate,
    required this.startTime,
    required this.endTime,
    required this.content,
    required this.source,
    this.linkedTodoId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['journal_date'] = Variable<String>(journalDate);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['content'] = Variable<String>(content);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || linkedTodoId != null) {
      map['linked_todo_id'] = Variable<int>(linkedTodoId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TimeBlocksCompanion toCompanion(bool nullToAbsent) {
    return TimeBlocksCompanion(
      id: Value(id),
      journalDate: Value(journalDate),
      startTime: Value(startTime),
      endTime: Value(endTime),
      content: Value(content),
      source: Value(source),
      linkedTodoId: linkedTodoId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTodoId),
      sortOrder: Value(sortOrder),
    );
  }

  factory TimeBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeBlock(
      id: serializer.fromJson<int>(json['id']),
      journalDate: serializer.fromJson<String>(json['journalDate']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      content: serializer.fromJson<String>(json['content']),
      source: serializer.fromJson<String>(json['source']),
      linkedTodoId: serializer.fromJson<int?>(json['linkedTodoId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'journalDate': serializer.toJson<String>(journalDate),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'content': serializer.toJson<String>(content),
      'source': serializer.toJson<String>(source),
      'linkedTodoId': serializer.toJson<int?>(linkedTodoId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TimeBlock copyWith({
    int? id,
    String? journalDate,
    String? startTime,
    String? endTime,
    String? content,
    String? source,
    Value<int?> linkedTodoId = const Value.absent(),
    int? sortOrder,
  }) => TimeBlock(
    id: id ?? this.id,
    journalDate: journalDate ?? this.journalDate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    content: content ?? this.content,
    source: source ?? this.source,
    linkedTodoId: linkedTodoId.present ? linkedTodoId.value : this.linkedTodoId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TimeBlock copyWithCompanion(TimeBlocksCompanion data) {
    return TimeBlock(
      id: data.id.present ? data.id.value : this.id,
      journalDate: data.journalDate.present
          ? data.journalDate.value
          : this.journalDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      content: data.content.present ? data.content.value : this.content,
      source: data.source.present ? data.source.value : this.source,
      linkedTodoId: data.linkedTodoId.present
          ? data.linkedTodoId.value
          : this.linkedTodoId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeBlock(')
          ..write('id: $id, ')
          ..write('journalDate: $journalDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('content: $content, ')
          ..write('source: $source, ')
          ..write('linkedTodoId: $linkedTodoId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    journalDate,
    startTime,
    endTime,
    content,
    source,
    linkedTodoId,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeBlock &&
          other.id == this.id &&
          other.journalDate == this.journalDate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.content == this.content &&
          other.source == this.source &&
          other.linkedTodoId == this.linkedTodoId &&
          other.sortOrder == this.sortOrder);
}

class TimeBlocksCompanion extends UpdateCompanion<TimeBlock> {
  final Value<int> id;
  final Value<String> journalDate;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> content;
  final Value<String> source;
  final Value<int?> linkedTodoId;
  final Value<int> sortOrder;
  const TimeBlocksCompanion({
    this.id = const Value.absent(),
    this.journalDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.content = const Value.absent(),
    this.source = const Value.absent(),
    this.linkedTodoId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TimeBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String journalDate,
    required String startTime,
    required String endTime,
    this.content = const Value.absent(),
    required String source,
    this.linkedTodoId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : journalDate = Value(journalDate),
       startTime = Value(startTime),
       endTime = Value(endTime),
       source = Value(source);
  static Insertable<TimeBlock> custom({
    Expression<int>? id,
    Expression<String>? journalDate,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? content,
    Expression<String>? source,
    Expression<int>? linkedTodoId,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (journalDate != null) 'journal_date': journalDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (content != null) 'content': content,
      if (source != null) 'source': source,
      if (linkedTodoId != null) 'linked_todo_id': linkedTodoId,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TimeBlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? journalDate,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? content,
    Value<String>? source,
    Value<int?>? linkedTodoId,
    Value<int>? sortOrder,
  }) {
    return TimeBlocksCompanion(
      id: id ?? this.id,
      journalDate: journalDate ?? this.journalDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      content: content ?? this.content,
      source: source ?? this.source,
      linkedTodoId: linkedTodoId ?? this.linkedTodoId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (journalDate.present) {
      map['journal_date'] = Variable<String>(journalDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (linkedTodoId.present) {
      map['linked_todo_id'] = Variable<int>(linkedTodoId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeBlocksCompanion(')
          ..write('id: $id, ')
          ..write('journalDate: $journalDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('content: $content, ')
          ..write('source: $source, ')
          ..write('linkedTodoId: $linkedTodoId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $PomodoroSessionsTable extends PomodoroSessions
    with TableInfo<$PomodoroSessionsTable, PomodoroSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PomodoroSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualSecondsMeta = const VerificationMeta(
    'actualSeconds',
  );
  @override
  late final GeneratedColumn<int> actualSeconds = GeneratedColumn<int>(
    'actual_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _interruptCountMeta = const VerificationMeta(
    'interruptCount',
  );
  @override
  late final GeneratedColumn<int> interruptCount = GeneratedColumn<int>(
    'interrupt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _linkedTodoIdMeta = const VerificationMeta(
    'linkedTodoId',
  );
  @override
  late final GeneratedColumn<int> linkedTodoId = GeneratedColumn<int>(
    'linked_todo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    durationMinutes,
    actualSeconds,
    interruptCount,
    completed,
    linkedTodoId,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pomodoro_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PomodoroSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('actual_seconds')) {
      context.handle(
        _actualSecondsMeta,
        actualSeconds.isAcceptableOrUnknown(
          data['actual_seconds']!,
          _actualSecondsMeta,
        ),
      );
    }
    if (data.containsKey('interrupt_count')) {
      context.handle(
        _interruptCountMeta,
        interruptCount.isAcceptableOrUnknown(
          data['interrupt_count']!,
          _interruptCountMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('linked_todo_id')) {
      context.handle(
        _linkedTodoIdMeta,
        linkedTodoId.isAcceptableOrUnknown(
          data['linked_todo_id']!,
          _linkedTodoIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PomodoroSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PomodoroSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      actualSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_seconds'],
      )!,
      interruptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interrupt_count'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      linkedTodoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_todo_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $PomodoroSessionsTable createAlias(String alias) {
    return $PomodoroSessionsTable(attachedDatabase, alias);
  }
}

class PomodoroSession extends DataClass implements Insertable<PomodoroSession> {
  final int id;
  final String date;
  final int durationMinutes;
  final int actualSeconds;
  final int interruptCount;
  final bool completed;
  final int? linkedTodoId;
  final DateTime startedAt;
  final DateTime? endedAt;
  const PomodoroSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.actualSeconds,
    required this.interruptCount,
    required this.completed,
    this.linkedTodoId,
    required this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['actual_seconds'] = Variable<int>(actualSeconds);
    map['interrupt_count'] = Variable<int>(interruptCount);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || linkedTodoId != null) {
      map['linked_todo_id'] = Variable<int>(linkedTodoId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  PomodoroSessionsCompanion toCompanion(bool nullToAbsent) {
    return PomodoroSessionsCompanion(
      id: Value(id),
      date: Value(date),
      durationMinutes: Value(durationMinutes),
      actualSeconds: Value(actualSeconds),
      interruptCount: Value(interruptCount),
      completed: Value(completed),
      linkedTodoId: linkedTodoId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTodoId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory PomodoroSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PomodoroSession(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      actualSeconds: serializer.fromJson<int>(json['actualSeconds']),
      interruptCount: serializer.fromJson<int>(json['interruptCount']),
      completed: serializer.fromJson<bool>(json['completed']),
      linkedTodoId: serializer.fromJson<int?>(json['linkedTodoId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'actualSeconds': serializer.toJson<int>(actualSeconds),
      'interruptCount': serializer.toJson<int>(interruptCount),
      'completed': serializer.toJson<bool>(completed),
      'linkedTodoId': serializer.toJson<int?>(linkedTodoId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  PomodoroSession copyWith({
    int? id,
    String? date,
    int? durationMinutes,
    int? actualSeconds,
    int? interruptCount,
    bool? completed,
    Value<int?> linkedTodoId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => PomodoroSession(
    id: id ?? this.id,
    date: date ?? this.date,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    actualSeconds: actualSeconds ?? this.actualSeconds,
    interruptCount: interruptCount ?? this.interruptCount,
    completed: completed ?? this.completed,
    linkedTodoId: linkedTodoId.present ? linkedTodoId.value : this.linkedTodoId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  PomodoroSession copyWithCompanion(PomodoroSessionsCompanion data) {
    return PomodoroSession(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      actualSeconds: data.actualSeconds.present
          ? data.actualSeconds.value
          : this.actualSeconds,
      interruptCount: data.interruptCount.present
          ? data.interruptCount.value
          : this.interruptCount,
      completed: data.completed.present ? data.completed.value : this.completed,
      linkedTodoId: data.linkedTodoId.present
          ? data.linkedTodoId.value
          : this.linkedTodoId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSession(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('interruptCount: $interruptCount, ')
          ..write('completed: $completed, ')
          ..write('linkedTodoId: $linkedTodoId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    durationMinutes,
    actualSeconds,
    interruptCount,
    completed,
    linkedTodoId,
    startedAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PomodoroSession &&
          other.id == this.id &&
          other.date == this.date &&
          other.durationMinutes == this.durationMinutes &&
          other.actualSeconds == this.actualSeconds &&
          other.interruptCount == this.interruptCount &&
          other.completed == this.completed &&
          other.linkedTodoId == this.linkedTodoId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class PomodoroSessionsCompanion extends UpdateCompanion<PomodoroSession> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> durationMinutes;
  final Value<int> actualSeconds;
  final Value<int> interruptCount;
  final Value<bool> completed;
  final Value<int?> linkedTodoId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  const PomodoroSessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    this.interruptCount = const Value.absent(),
    this.completed = const Value.absent(),
    this.linkedTodoId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
  });
  PomodoroSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required int durationMinutes,
    this.actualSeconds = const Value.absent(),
    this.interruptCount = const Value.absent(),
    this.completed = const Value.absent(),
    this.linkedTodoId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
  }) : date = Value(date),
       durationMinutes = Value(durationMinutes),
       startedAt = Value(startedAt);
  static Insertable<PomodoroSession> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? durationMinutes,
    Expression<int>? actualSeconds,
    Expression<int>? interruptCount,
    Expression<bool>? completed,
    Expression<int>? linkedTodoId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (actualSeconds != null) 'actual_seconds': actualSeconds,
      if (interruptCount != null) 'interrupt_count': interruptCount,
      if (completed != null) 'completed': completed,
      if (linkedTodoId != null) 'linked_todo_id': linkedTodoId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
    });
  }

  PomodoroSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? durationMinutes,
    Value<int>? actualSeconds,
    Value<int>? interruptCount,
    Value<bool>? completed,
    Value<int?>? linkedTodoId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
  }) {
    return PomodoroSessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      interruptCount: interruptCount ?? this.interruptCount,
      completed: completed ?? this.completed,
      linkedTodoId: linkedTodoId ?? this.linkedTodoId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (actualSeconds.present) {
      map['actual_seconds'] = Variable<int>(actualSeconds.value);
    }
    if (interruptCount.present) {
      map['interrupt_count'] = Variable<int>(interruptCount.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (linkedTodoId.present) {
      map['linked_todo_id'] = Variable<int>(linkedTodoId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PomodoroSessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('interruptCount: $interruptCount, ')
          ..write('completed: $completed, ')
          ..write('linkedTodoId: $linkedTodoId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }
}

class $SleepRecordsTable extends SleepRecords
    with TableInfo<$SleepRecordsTable, SleepRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _targetBedtimeMeta = const VerificationMeta(
    'targetBedtime',
  );
  @override
  late final GeneratedColumn<String> targetBedtime = GeneratedColumn<String>(
    'target_bedtime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('23:00'),
  );
  static const VerificationMeta _targetWakeTimeMeta = const VerificationMeta(
    'targetWakeTime',
  );
  @override
  late final GeneratedColumn<String> targetWakeTime = GeneratedColumn<String>(
    'target_wake_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:00'),
  );
  static const VerificationMeta _actualBedtimeMeta = const VerificationMeta(
    'actualBedtime',
  );
  @override
  late final GeneratedColumn<DateTime> actualBedtime =
      GeneratedColumn<DateTime>(
        'actual_bedtime',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualWakeTimeMeta = const VerificationMeta(
    'actualWakeTime',
  );
  @override
  late final GeneratedColumn<DateTime> actualWakeTime =
      GeneratedColumn<DateTime>(
        'actual_wake_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sleepScoreMeta = const VerificationMeta(
    'sleepScore',
  );
  @override
  late final GeneratedColumn<int> sleepScore = GeneratedColumn<int>(
    'sleep_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  @override
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalScoreMeta = const VerificationMeta(
    'totalScore',
  );
  @override
  late final GeneratedColumn<int> totalScore = GeneratedColumn<int>(
    'total_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    targetBedtime,
    targetWakeTime,
    actualBedtime,
    actualWakeTime,
    sleepScore,
    streakDays,
    totalScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('target_bedtime')) {
      context.handle(
        _targetBedtimeMeta,
        targetBedtime.isAcceptableOrUnknown(
          data['target_bedtime']!,
          _targetBedtimeMeta,
        ),
      );
    }
    if (data.containsKey('target_wake_time')) {
      context.handle(
        _targetWakeTimeMeta,
        targetWakeTime.isAcceptableOrUnknown(
          data['target_wake_time']!,
          _targetWakeTimeMeta,
        ),
      );
    }
    if (data.containsKey('actual_bedtime')) {
      context.handle(
        _actualBedtimeMeta,
        actualBedtime.isAcceptableOrUnknown(
          data['actual_bedtime']!,
          _actualBedtimeMeta,
        ),
      );
    }
    if (data.containsKey('actual_wake_time')) {
      context.handle(
        _actualWakeTimeMeta,
        actualWakeTime.isAcceptableOrUnknown(
          data['actual_wake_time']!,
          _actualWakeTimeMeta,
        ),
      );
    }
    if (data.containsKey('sleep_score')) {
      context.handle(
        _sleepScoreMeta,
        sleepScore.isAcceptableOrUnknown(data['sleep_score']!, _sleepScoreMeta),
      );
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('total_score')) {
      context.handle(
        _totalScoreMeta,
        totalScore.isAcceptableOrUnknown(data['total_score']!, _totalScoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      targetBedtime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_bedtime'],
      )!,
      targetWakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_wake_time'],
      )!,
      actualBedtime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_bedtime'],
      ),
      actualWakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_wake_time'],
      ),
      sleepScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_score'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      totalScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_score'],
      )!,
    );
  }

  @override
  $SleepRecordsTable createAlias(String alias) {
    return $SleepRecordsTable(attachedDatabase, alias);
  }
}

class SleepRecord extends DataClass implements Insertable<SleepRecord> {
  final int id;
  final String date;
  final String targetBedtime;
  final String targetWakeTime;
  final DateTime? actualBedtime;
  final DateTime? actualWakeTime;
  final int sleepScore;
  final int streakDays;
  final int totalScore;
  const SleepRecord({
    required this.id,
    required this.date,
    required this.targetBedtime,
    required this.targetWakeTime,
    this.actualBedtime,
    this.actualWakeTime,
    required this.sleepScore,
    required this.streakDays,
    required this.totalScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['target_bedtime'] = Variable<String>(targetBedtime);
    map['target_wake_time'] = Variable<String>(targetWakeTime);
    if (!nullToAbsent || actualBedtime != null) {
      map['actual_bedtime'] = Variable<DateTime>(actualBedtime);
    }
    if (!nullToAbsent || actualWakeTime != null) {
      map['actual_wake_time'] = Variable<DateTime>(actualWakeTime);
    }
    map['sleep_score'] = Variable<int>(sleepScore);
    map['streak_days'] = Variable<int>(streakDays);
    map['total_score'] = Variable<int>(totalScore);
    return map;
  }

  SleepRecordsCompanion toCompanion(bool nullToAbsent) {
    return SleepRecordsCompanion(
      id: Value(id),
      date: Value(date),
      targetBedtime: Value(targetBedtime),
      targetWakeTime: Value(targetWakeTime),
      actualBedtime: actualBedtime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualBedtime),
      actualWakeTime: actualWakeTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWakeTime),
      sleepScore: Value(sleepScore),
      streakDays: Value(streakDays),
      totalScore: Value(totalScore),
    );
  }

  factory SleepRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepRecord(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      targetBedtime: serializer.fromJson<String>(json['targetBedtime']),
      targetWakeTime: serializer.fromJson<String>(json['targetWakeTime']),
      actualBedtime: serializer.fromJson<DateTime?>(json['actualBedtime']),
      actualWakeTime: serializer.fromJson<DateTime?>(json['actualWakeTime']),
      sleepScore: serializer.fromJson<int>(json['sleepScore']),
      streakDays: serializer.fromJson<int>(json['streakDays']),
      totalScore: serializer.fromJson<int>(json['totalScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'targetBedtime': serializer.toJson<String>(targetBedtime),
      'targetWakeTime': serializer.toJson<String>(targetWakeTime),
      'actualBedtime': serializer.toJson<DateTime?>(actualBedtime),
      'actualWakeTime': serializer.toJson<DateTime?>(actualWakeTime),
      'sleepScore': serializer.toJson<int>(sleepScore),
      'streakDays': serializer.toJson<int>(streakDays),
      'totalScore': serializer.toJson<int>(totalScore),
    };
  }

  SleepRecord copyWith({
    int? id,
    String? date,
    String? targetBedtime,
    String? targetWakeTime,
    Value<DateTime?> actualBedtime = const Value.absent(),
    Value<DateTime?> actualWakeTime = const Value.absent(),
    int? sleepScore,
    int? streakDays,
    int? totalScore,
  }) => SleepRecord(
    id: id ?? this.id,
    date: date ?? this.date,
    targetBedtime: targetBedtime ?? this.targetBedtime,
    targetWakeTime: targetWakeTime ?? this.targetWakeTime,
    actualBedtime: actualBedtime.present
        ? actualBedtime.value
        : this.actualBedtime,
    actualWakeTime: actualWakeTime.present
        ? actualWakeTime.value
        : this.actualWakeTime,
    sleepScore: sleepScore ?? this.sleepScore,
    streakDays: streakDays ?? this.streakDays,
    totalScore: totalScore ?? this.totalScore,
  );
  SleepRecord copyWithCompanion(SleepRecordsCompanion data) {
    return SleepRecord(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      targetBedtime: data.targetBedtime.present
          ? data.targetBedtime.value
          : this.targetBedtime,
      targetWakeTime: data.targetWakeTime.present
          ? data.targetWakeTime.value
          : this.targetWakeTime,
      actualBedtime: data.actualBedtime.present
          ? data.actualBedtime.value
          : this.actualBedtime,
      actualWakeTime: data.actualWakeTime.present
          ? data.actualWakeTime.value
          : this.actualWakeTime,
      sleepScore: data.sleepScore.present
          ? data.sleepScore.value
          : this.sleepScore,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      totalScore: data.totalScore.present
          ? data.totalScore.value
          : this.totalScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepRecord(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('targetBedtime: $targetBedtime, ')
          ..write('targetWakeTime: $targetWakeTime, ')
          ..write('actualBedtime: $actualBedtime, ')
          ..write('actualWakeTime: $actualWakeTime, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('streakDays: $streakDays, ')
          ..write('totalScore: $totalScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    targetBedtime,
    targetWakeTime,
    actualBedtime,
    actualWakeTime,
    sleepScore,
    streakDays,
    totalScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepRecord &&
          other.id == this.id &&
          other.date == this.date &&
          other.targetBedtime == this.targetBedtime &&
          other.targetWakeTime == this.targetWakeTime &&
          other.actualBedtime == this.actualBedtime &&
          other.actualWakeTime == this.actualWakeTime &&
          other.sleepScore == this.sleepScore &&
          other.streakDays == this.streakDays &&
          other.totalScore == this.totalScore);
}

class SleepRecordsCompanion extends UpdateCompanion<SleepRecord> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> targetBedtime;
  final Value<String> targetWakeTime;
  final Value<DateTime?> actualBedtime;
  final Value<DateTime?> actualWakeTime;
  final Value<int> sleepScore;
  final Value<int> streakDays;
  final Value<int> totalScore;
  const SleepRecordsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.targetBedtime = const Value.absent(),
    this.targetWakeTime = const Value.absent(),
    this.actualBedtime = const Value.absent(),
    this.actualWakeTime = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.totalScore = const Value.absent(),
  });
  SleepRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.targetBedtime = const Value.absent(),
    this.targetWakeTime = const Value.absent(),
    this.actualBedtime = const Value.absent(),
    this.actualWakeTime = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.totalScore = const Value.absent(),
  }) : date = Value(date);
  static Insertable<SleepRecord> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? targetBedtime,
    Expression<String>? targetWakeTime,
    Expression<DateTime>? actualBedtime,
    Expression<DateTime>? actualWakeTime,
    Expression<int>? sleepScore,
    Expression<int>? streakDays,
    Expression<int>? totalScore,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (targetBedtime != null) 'target_bedtime': targetBedtime,
      if (targetWakeTime != null) 'target_wake_time': targetWakeTime,
      if (actualBedtime != null) 'actual_bedtime': actualBedtime,
      if (actualWakeTime != null) 'actual_wake_time': actualWakeTime,
      if (sleepScore != null) 'sleep_score': sleepScore,
      if (streakDays != null) 'streak_days': streakDays,
      if (totalScore != null) 'total_score': totalScore,
    });
  }

  SleepRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? targetBedtime,
    Value<String>? targetWakeTime,
    Value<DateTime?>? actualBedtime,
    Value<DateTime?>? actualWakeTime,
    Value<int>? sleepScore,
    Value<int>? streakDays,
    Value<int>? totalScore,
  }) {
    return SleepRecordsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      targetBedtime: targetBedtime ?? this.targetBedtime,
      targetWakeTime: targetWakeTime ?? this.targetWakeTime,
      actualBedtime: actualBedtime ?? this.actualBedtime,
      actualWakeTime: actualWakeTime ?? this.actualWakeTime,
      sleepScore: sleepScore ?? this.sleepScore,
      streakDays: streakDays ?? this.streakDays,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (targetBedtime.present) {
      map['target_bedtime'] = Variable<String>(targetBedtime.value);
    }
    if (targetWakeTime.present) {
      map['target_wake_time'] = Variable<String>(targetWakeTime.value);
    }
    if (actualBedtime.present) {
      map['actual_bedtime'] = Variable<DateTime>(actualBedtime.value);
    }
    if (actualWakeTime.present) {
      map['actual_wake_time'] = Variable<DateTime>(actualWakeTime.value);
    }
    if (sleepScore.present) {
      map['sleep_score'] = Variable<int>(sleepScore.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (totalScore.present) {
      map['total_score'] = Variable<int>(totalScore.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepRecordsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('targetBedtime: $targetBedtime, ')
          ..write('targetWakeTime: $targetWakeTime, ')
          ..write('actualBedtime: $actualBedtime, ')
          ..write('actualWakeTime: $actualWakeTime, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('streakDays: $streakDays, ')
          ..write('totalScore: $totalScore')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyJournalsTable dailyJournals = $DailyJournalsTable(this);
  late final $TodoItemsTable todoItems = $TodoItemsTable(this);
  late final $TimeBlocksTable timeBlocks = $TimeBlocksTable(this);
  late final $PomodoroSessionsTable pomodoroSessions = $PomodoroSessionsTable(
    this,
  );
  late final $SleepRecordsTable sleepRecords = $SleepRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailyJournals,
    todoItems,
    timeBlocks,
    pomodoroSessions,
    sleepRecords,
  ];
}

typedef $$DailyJournalsTableCreateCompanionBuilder =
    DailyJournalsCompanion Function({
      Value<int> id,
      required String date,
      Value<String> notes,
      Value<int?> availableStudyMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$DailyJournalsTableUpdateCompanionBuilder =
    DailyJournalsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> notes,
      Value<int?> availableStudyMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DailyJournalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyJournalsTable> {
  $$DailyJournalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableStudyMinutes => $composableBuilder(
    column: $table.availableStudyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyJournalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyJournalsTable> {
  $$DailyJournalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableStudyMinutes => $composableBuilder(
    column: $table.availableStudyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyJournalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyJournalsTable> {
  $$DailyJournalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get availableStudyMinutes => $composableBuilder(
    column: $table.availableStudyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyJournalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyJournalsTable,
          DailyJournal,
          $$DailyJournalsTableFilterComposer,
          $$DailyJournalsTableOrderingComposer,
          $$DailyJournalsTableAnnotationComposer,
          $$DailyJournalsTableCreateCompanionBuilder,
          $$DailyJournalsTableUpdateCompanionBuilder,
          (
            DailyJournal,
            BaseReferences<_$AppDatabase, $DailyJournalsTable, DailyJournal>,
          ),
          DailyJournal,
          PrefetchHooks Function()
        > {
  $$DailyJournalsTableTableManager(_$AppDatabase db, $DailyJournalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyJournalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyJournalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyJournalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int?> availableStudyMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyJournalsCompanion(
                id: id,
                date: date,
                notes: notes,
                availableStudyMinutes: availableStudyMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<String> notes = const Value.absent(),
                Value<int?> availableStudyMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailyJournalsCompanion.insert(
                id: id,
                date: date,
                notes: notes,
                availableStudyMinutes: availableStudyMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyJournalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyJournalsTable,
      DailyJournal,
      $$DailyJournalsTableFilterComposer,
      $$DailyJournalsTableOrderingComposer,
      $$DailyJournalsTableAnnotationComposer,
      $$DailyJournalsTableCreateCompanionBuilder,
      $$DailyJournalsTableUpdateCompanionBuilder,
      (
        DailyJournal,
        BaseReferences<_$AppDatabase, $DailyJournalsTable, DailyJournal>,
      ),
      DailyJournal,
      PrefetchHooks Function()
    >;
typedef $$TodoItemsTableCreateCompanionBuilder =
    TodoItemsCompanion Function({
      Value<int> id,
      required String journalDate,
      Value<String> content,
      Value<int> priority,
      Value<bool> completed,
      Value<int> sortOrder,
    });
typedef $$TodoItemsTableUpdateCompanionBuilder =
    TodoItemsCompanion Function({
      Value<int> id,
      Value<String> journalDate,
      Value<String> content,
      Value<int> priority,
      Value<bool> completed,
      Value<int> sortOrder,
    });

class $$TodoItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TodoItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoItemsTable,
          TodoItem,
          $$TodoItemsTableFilterComposer,
          $$TodoItemsTableOrderingComposer,
          $$TodoItemsTableAnnotationComposer,
          $$TodoItemsTableCreateCompanionBuilder,
          $$TodoItemsTableUpdateCompanionBuilder,
          (TodoItem, BaseReferences<_$AppDatabase, $TodoItemsTable, TodoItem>),
          TodoItem,
          PrefetchHooks Function()
        > {
  $$TodoItemsTableTableManager(_$AppDatabase db, $TodoItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> journalDate = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TodoItemsCompanion(
                id: id,
                journalDate: journalDate,
                content: content,
                priority: priority,
                completed: completed,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String journalDate,
                Value<String> content = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TodoItemsCompanion.insert(
                id: id,
                journalDate: journalDate,
                content: content,
                priority: priority,
                completed: completed,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoItemsTable,
      TodoItem,
      $$TodoItemsTableFilterComposer,
      $$TodoItemsTableOrderingComposer,
      $$TodoItemsTableAnnotationComposer,
      $$TodoItemsTableCreateCompanionBuilder,
      $$TodoItemsTableUpdateCompanionBuilder,
      (TodoItem, BaseReferences<_$AppDatabase, $TodoItemsTable, TodoItem>),
      TodoItem,
      PrefetchHooks Function()
    >;
typedef $$TimeBlocksTableCreateCompanionBuilder =
    TimeBlocksCompanion Function({
      Value<int> id,
      required String journalDate,
      required String startTime,
      required String endTime,
      Value<String> content,
      required String source,
      Value<int?> linkedTodoId,
      Value<int> sortOrder,
    });
typedef $$TimeBlocksTableUpdateCompanionBuilder =
    TimeBlocksCompanion Function({
      Value<int> id,
      Value<String> journalDate,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> content,
      Value<String> source,
      Value<int?> linkedTodoId,
      Value<int> sortOrder,
    });

class $$TimeBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $TimeBlocksTable> {
  $$TimeBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedTodoId => $composableBuilder(
    column: $table.linkedTodoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimeBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeBlocksTable> {
  $$TimeBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedTodoId => $composableBuilder(
    column: $table.linkedTodoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeBlocksTable> {
  $$TimeBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get linkedTodoId => $composableBuilder(
    column: $table.linkedTodoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$TimeBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeBlocksTable,
          TimeBlock,
          $$TimeBlocksTableFilterComposer,
          $$TimeBlocksTableOrderingComposer,
          $$TimeBlocksTableAnnotationComposer,
          $$TimeBlocksTableCreateCompanionBuilder,
          $$TimeBlocksTableUpdateCompanionBuilder,
          (
            TimeBlock,
            BaseReferences<_$AppDatabase, $TimeBlocksTable, TimeBlock>,
          ),
          TimeBlock,
          PrefetchHooks Function()
        > {
  $$TimeBlocksTableTableManager(_$AppDatabase db, $TimeBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> journalDate = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> linkedTodoId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TimeBlocksCompanion(
                id: id,
                journalDate: journalDate,
                startTime: startTime,
                endTime: endTime,
                content: content,
                source: source,
                linkedTodoId: linkedTodoId,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String journalDate,
                required String startTime,
                required String endTime,
                Value<String> content = const Value.absent(),
                required String source,
                Value<int?> linkedTodoId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TimeBlocksCompanion.insert(
                id: id,
                journalDate: journalDate,
                startTime: startTime,
                endTime: endTime,
                content: content,
                source: source,
                linkedTodoId: linkedTodoId,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimeBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeBlocksTable,
      TimeBlock,
      $$TimeBlocksTableFilterComposer,
      $$TimeBlocksTableOrderingComposer,
      $$TimeBlocksTableAnnotationComposer,
      $$TimeBlocksTableCreateCompanionBuilder,
      $$TimeBlocksTableUpdateCompanionBuilder,
      (TimeBlock, BaseReferences<_$AppDatabase, $TimeBlocksTable, TimeBlock>),
      TimeBlock,
      PrefetchHooks Function()
    >;
typedef $$PomodoroSessionsTableCreateCompanionBuilder =
    PomodoroSessionsCompanion Function({
      Value<int> id,
      required String date,
      required int durationMinutes,
      Value<int> actualSeconds,
      Value<int> interruptCount,
      Value<bool> completed,
      Value<int?> linkedTodoId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
    });
typedef $$PomodoroSessionsTableUpdateCompanionBuilder =
    PomodoroSessionsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> durationMinutes,
      Value<int> actualSeconds,
      Value<int> interruptCount,
      Value<bool> completed,
      Value<int?> linkedTodoId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
    });

class $$PomodoroSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interruptCount => $composableBuilder(
    column: $table.interruptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedTodoId => $composableBuilder(
    column: $table.linkedTodoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PomodoroSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interruptCount => $composableBuilder(
    column: $table.interruptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedTodoId => $composableBuilder(
    column: $table.linkedTodoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PomodoroSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PomodoroSessionsTable> {
  $$PomodoroSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interruptCount => $composableBuilder(
    column: $table.interruptCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get linkedTodoId => $composableBuilder(
    column: $table.linkedTodoId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);
}

class $$PomodoroSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PomodoroSessionsTable,
          PomodoroSession,
          $$PomodoroSessionsTableFilterComposer,
          $$PomodoroSessionsTableOrderingComposer,
          $$PomodoroSessionsTableAnnotationComposer,
          $$PomodoroSessionsTableCreateCompanionBuilder,
          $$PomodoroSessionsTableUpdateCompanionBuilder,
          (
            PomodoroSession,
            BaseReferences<
              _$AppDatabase,
              $PomodoroSessionsTable,
              PomodoroSession
            >,
          ),
          PomodoroSession,
          PrefetchHooks Function()
        > {
  $$PomodoroSessionsTableTableManager(
    _$AppDatabase db,
    $PomodoroSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PomodoroSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PomodoroSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PomodoroSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                Value<int> interruptCount = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int?> linkedTodoId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
              }) => PomodoroSessionsCompanion(
                id: id,
                date: date,
                durationMinutes: durationMinutes,
                actualSeconds: actualSeconds,
                interruptCount: interruptCount,
                completed: completed,
                linkedTodoId: linkedTodoId,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required int durationMinutes,
                Value<int> actualSeconds = const Value.absent(),
                Value<int> interruptCount = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int?> linkedTodoId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
              }) => PomodoroSessionsCompanion.insert(
                id: id,
                date: date,
                durationMinutes: durationMinutes,
                actualSeconds: actualSeconds,
                interruptCount: interruptCount,
                completed: completed,
                linkedTodoId: linkedTodoId,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PomodoroSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PomodoroSessionsTable,
      PomodoroSession,
      $$PomodoroSessionsTableFilterComposer,
      $$PomodoroSessionsTableOrderingComposer,
      $$PomodoroSessionsTableAnnotationComposer,
      $$PomodoroSessionsTableCreateCompanionBuilder,
      $$PomodoroSessionsTableUpdateCompanionBuilder,
      (
        PomodoroSession,
        BaseReferences<_$AppDatabase, $PomodoroSessionsTable, PomodoroSession>,
      ),
      PomodoroSession,
      PrefetchHooks Function()
    >;
typedef $$SleepRecordsTableCreateCompanionBuilder =
    SleepRecordsCompanion Function({
      Value<int> id,
      required String date,
      Value<String> targetBedtime,
      Value<String> targetWakeTime,
      Value<DateTime?> actualBedtime,
      Value<DateTime?> actualWakeTime,
      Value<int> sleepScore,
      Value<int> streakDays,
      Value<int> totalScore,
    });
typedef $$SleepRecordsTableUpdateCompanionBuilder =
    SleepRecordsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> targetBedtime,
      Value<String> targetWakeTime,
      Value<DateTime?> actualBedtime,
      Value<DateTime?> actualWakeTime,
      Value<int> sleepScore,
      Value<int> streakDays,
      Value<int> totalScore,
    });

class $$SleepRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetBedtime => $composableBuilder(
    column: $table.targetBedtime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetWakeTime => $composableBuilder(
    column: $table.targetWakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualBedtime => $composableBuilder(
    column: $table.actualBedtime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualWakeTime => $composableBuilder(
    column: $table.actualWakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetBedtime => $composableBuilder(
    column: $table.targetBedtime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetWakeTime => $composableBuilder(
    column: $table.targetWakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualBedtime => $composableBuilder(
    column: $table.actualBedtime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualWakeTime => $composableBuilder(
    column: $table.actualWakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get targetBedtime => $composableBuilder(
    column: $table.targetBedtime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetWakeTime => $composableBuilder(
    column: $table.targetWakeTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualBedtime => $composableBuilder(
    column: $table.actualBedtime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualWakeTime => $composableBuilder(
    column: $table.actualWakeTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalScore => $composableBuilder(
    column: $table.totalScore,
    builder: (column) => column,
  );
}

class $$SleepRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepRecordsTable,
          SleepRecord,
          $$SleepRecordsTableFilterComposer,
          $$SleepRecordsTableOrderingComposer,
          $$SleepRecordsTableAnnotationComposer,
          $$SleepRecordsTableCreateCompanionBuilder,
          $$SleepRecordsTableUpdateCompanionBuilder,
          (
            SleepRecord,
            BaseReferences<_$AppDatabase, $SleepRecordsTable, SleepRecord>,
          ),
          SleepRecord,
          PrefetchHooks Function()
        > {
  $$SleepRecordsTableTableManager(_$AppDatabase db, $SleepRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> targetBedtime = const Value.absent(),
                Value<String> targetWakeTime = const Value.absent(),
                Value<DateTime?> actualBedtime = const Value.absent(),
                Value<DateTime?> actualWakeTime = const Value.absent(),
                Value<int> sleepScore = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> totalScore = const Value.absent(),
              }) => SleepRecordsCompanion(
                id: id,
                date: date,
                targetBedtime: targetBedtime,
                targetWakeTime: targetWakeTime,
                actualBedtime: actualBedtime,
                actualWakeTime: actualWakeTime,
                sleepScore: sleepScore,
                streakDays: streakDays,
                totalScore: totalScore,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<String> targetBedtime = const Value.absent(),
                Value<String> targetWakeTime = const Value.absent(),
                Value<DateTime?> actualBedtime = const Value.absent(),
                Value<DateTime?> actualWakeTime = const Value.absent(),
                Value<int> sleepScore = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> totalScore = const Value.absent(),
              }) => SleepRecordsCompanion.insert(
                id: id,
                date: date,
                targetBedtime: targetBedtime,
                targetWakeTime: targetWakeTime,
                actualBedtime: actualBedtime,
                actualWakeTime: actualWakeTime,
                sleepScore: sleepScore,
                streakDays: streakDays,
                totalScore: totalScore,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepRecordsTable,
      SleepRecord,
      $$SleepRecordsTableFilterComposer,
      $$SleepRecordsTableOrderingComposer,
      $$SleepRecordsTableAnnotationComposer,
      $$SleepRecordsTableCreateCompanionBuilder,
      $$SleepRecordsTableUpdateCompanionBuilder,
      (
        SleepRecord,
        BaseReferences<_$AppDatabase, $SleepRecordsTable, SleepRecord>,
      ),
      SleepRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyJournalsTableTableManager get dailyJournals =>
      $$DailyJournalsTableTableManager(_db, _db.dailyJournals);
  $$TodoItemsTableTableManager get todoItems =>
      $$TodoItemsTableTableManager(_db, _db.todoItems);
  $$TimeBlocksTableTableManager get timeBlocks =>
      $$TimeBlocksTableTableManager(_db, _db.timeBlocks);
  $$PomodoroSessionsTableTableManager get pomodoroSessions =>
      $$PomodoroSessionsTableTableManager(_db, _db.pomodoroSessions);
  $$SleepRecordsTableTableManager get sleepRecords =>
      $$SleepRecordsTableTableManager(_db, _db.sleepRecords);
}
