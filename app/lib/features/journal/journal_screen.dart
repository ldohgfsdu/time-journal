import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/copy.dart';
import '../../app/gentle_feedback.dart';
import '../../app/shell_navigation.dart';
import '../../app/theme.dart';
import '../../data/local/app_prefs.dart';
import '../../data/local/database.dart';
import 'providers/journal_providers.dart';
import 'widgets/action_pill_button.dart';
import 'widgets/first_todo_hint.dart';
import 'widgets/paper_background.dart';
import 'widgets/section_card.dart';
import 'widgets/today_comparison_section.dart';
import 'widgets/today_stats_card.dart';
import 'widgets/schedule_sheet.dart';
import 'widgets/todo_action_sheet.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final Map<int, TextEditingController> _todoControllers = {};
  final List<int> _draftTodoIds = [];
  int _nextDraftId = -1;
  final TextEditingController _notesController = TextEditingController();
  Timer? _notesDebounce;
  String? _loadedNotesDate;
  bool _firstTodoHintEligible = false;
  bool _showFirstTodoHint = false;
  int? _firstTodoHintItemId;
  bool _showAllTodos = false;

  @override
  void initState() {
    super.initState();
    _initFirstTodoHint();
  }

  Future<void> _initFirstTodoHint() async {
    if (await AppPrefs.hasShownFirstTodoHint()) return;
    final hasContent =
        await ref.read(journalRepositoryProvider).hasAnyTodoContent();
    if (hasContent) {
      await AppPrefs.markFirstTodoHintShown();
      return;
    }
    if (mounted) setState(() => _firstTodoHintEligible = true);
  }

  @override
  void dispose() {
    _notesDebounce?.cancel();
    _notesController.dispose();
    for (final c in _todoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _shiftDate(int days) {
    final current = ref.read(selectedDateProvider);
    ref.read(selectedDateProvider.notifier).state =
        current.add(Duration(days: days));
    setState(() {
      _showAllTodos = false;
      _clearDraftTodos();
    });
  }

  void _clearDraftTodos() {
    for (final id in _draftTodoIds) {
      _todoControllers.remove(id)?.dispose();
    }
    _draftTodoIds.clear();
  }

  bool _isDraftTodo(int id) => id < 0;

  String _normalizeTodoContent(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty || trimmed == AppCopy.journalTodoHint) return '';
    return trimmed;
  }

  TodoItem _draftTodo(String dateKey, int id) => TodoItem(
        id: id,
        journalDate: dateKey,
        content: '',
        priority: 0,
        completed: false,
        sortOrder: -1,
      );

  void _addDraftTodo() {
    final id = _nextDraftId--;
    _draftTodoIds.add(id);
    _todoControllers[id] = TextEditingController();
    setState(() {});
  }

  Future<void> _persistTodo(String dateKey, TodoItem item, String content) async {
    final normalized = _normalizeTodoContent(content);
    if (_isDraftTodo(item.id)) {
      if (normalized.isEmpty) return;
      final created = await ref
          .read(journalRepositoryProvider)
          .createTodo(dateKey, normalized);
      _todoControllers.remove(item.id)?.dispose();
      _draftTodoIds.remove(item.id);
      _todoControllers[created.id] = TextEditingController(text: normalized);
      ref.invalidate(journalSnapshotProvider);
      if (_firstTodoHintEligible) {
        setState(() {
          _firstTodoHintEligible = false;
          _showFirstTodoHint = true;
          _firstTodoHintItemId = created.id;
        });
        await AppPrefs.markFirstTodoHintShown();
        GentleFeedback.lightTap();
      }
      return;
    }

    final wasEmpty = item.content.trim().isEmpty;
    final nowHasContent = normalized.isNotEmpty;
    if (!nowHasContent) {
      await _deleteTodo(item);
      return;
    }
    await ref
        .read(journalRepositoryProvider)
        .updateTodo(item.copyWith(content: normalized));
    ref.invalidate(journalSnapshotProvider);
    if (_firstTodoHintEligible && wasEmpty && nowHasContent) {
      setState(() {
        _firstTodoHintEligible = false;
        _showFirstTodoHint = true;
        _firstTodoHintItemId = item.id;
      });
      await AppPrefs.markFirstTodoHintShown();
      GentleFeedback.lightTap();
    }
  }

  Future<void> _deleteTodo(TodoItem item) async {
    if (_isDraftTodo(item.id)) {
      _todoControllers.remove(item.id)?.dispose();
      _draftTodoIds.remove(item.id);
      setState(() {});
      return;
    }
    await ref.read(journalRepositoryProvider).removeTodo(item.id);
    _todoControllers.remove(item.id)?.dispose();
    if (_firstTodoHintItemId == item.id) {
      setState(() {
        _showFirstTodoHint = false;
        _firstTodoHintItemId = null;
      });
    }
    ref.invalidate(journalSnapshotProvider);
  }

  Future<void> _toggleTodo(TodoItem item) async {
    await ref.read(journalRepositoryProvider).updateTodo(
          item.copyWith(completed: !item.completed),
        );
    ref.invalidate(journalSnapshotProvider);
  }

  void _saveNotesDebounced(String date, String notes) {
    _notesDebounce?.cancel();
    _notesDebounce = Timer(const Duration(milliseconds: 500), () async {
      await ref.read(journalRepositoryProvider).saveNotes(date, notes);
    });
  }

  TextEditingController _controllerForTodo(TodoItem item) {
    return _todoControllers.putIfAbsent(
      item.id,
      () => TextEditingController(text: item.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);
    final dateKey = ref.watch(selectedDateKeyProvider);
    final snapshotAsync = ref.watch(journalSnapshotProvider);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isToday = dateKey == todayKey;
    final weekday = DateFormat('EEEE', 'zh_CN').format(date);
    final displayDate = DateFormat('yyyy年M月d日').format(date);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        title: const Text(AppCopy.journalTitle),
        leading: IconButton(
          onPressed: () => _shiftDate(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => _shiftDate(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      body: PaperBackground(
        child: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.tomato)),
          error: (e, _) => Center(child: Text(AppCopy.loadErrorDetail(e))),
          data: (snapshot) {
            if (_loadedNotesDate != dateKey) {
              _loadedNotesDate = dateKey;
              _notesController.text = snapshot.journal.notes;
            }

            final allTodos = snapshot.todos;
            final scheduledIds = snapshot.comparisonSlots
                .where((s) => s.planned?.linkedTodoId != null)
                .map((s) => s.planned!.linkedTodoId!)
                .toSet();
            final unscheduledIncomplete = allTodos
                .where((t) =>
                    !t.completed &&
                    t.content.trim().isNotEmpty &&
                    !scheduledIds.contains(t.id))
                .toList();
            final completedTodos = allTodos
                .where((t) => t.completed && t.content.trim().isNotEmpty)
                .toList();
            final incompleteTodoCount = unscheduledIncomplete.length;
            final draftTodos =
                _draftTodoIds.map((id) => _draftTodo(dateKey, id)).toList();
            final visiblePersisted = _showAllTodos
                ? unscheduledIncomplete
                : unscheduledIncomplete.take(5).toList();
            final visibleTodos = [...draftTodos, ...visiblePersisted];
            final hiddenCount = _showAllTodos
                ? 0
                : unscheduledIncomplete.length - visiblePersisted.length;
            final completelyEmpty =
                allTodos.isEmpty && snapshot.comparisonSlots.isEmpty;

            return RefreshIndicator(
              color: AppTheme.tomato,
              onRefresh: () async => ref.invalidate(journalSnapshotProvider),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  _DateHeader(
                    displayDate: displayDate,
                    weekday: weekday,
                    attendanceHint: isToday
                        ? '${snapshot.comparisonSlots.length} 个时段 · $incompleteTodoCount 项待办'
                        : null,
                  ),
                  SectionCard(
                    title: AppCopy.journalTodoTitle,
                    subtitle: AppCopy.journalTodoSubtitle,
                    dense: allTodos.isEmpty && draftTodos.isEmpty,
                    trailing: ActionPillButton(
                      label: AppCopy.journalTodoAdd,
                      onPressed: _addDraftTodo,
                    ),
                    child: Column(
                      children: [
                        if (allTodos.isEmpty && draftTodos.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              completelyEmpty
                                  ? AppCopy.journalTodoHint
                                  : AppCopy.journalTodoEmpty,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        else ...[
                          for (var i = 0; i < visibleTodos.length; i++)
                            _buildTodoRow(dateKey, visibleTodos[i]),
                          if (hiddenCount > 0)
                            TextButton(
                              onPressed: () =>
                                  setState(() => _showAllTodos = true),
                              child: Text(
                                AppCopy.journalTodoShowMoreCount(hiddenCount),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  if (completedTodos.isNotEmpty)
                    SectionCard(
                      title: '已完成',
                      dense: true,
                      child: Opacity(
                        opacity: 0.72,
                        child: Column(
                          children: [
                            for (final todo in completedTodos)
                              _buildTodoRow(dateKey, todo),
                          ],
                        ),
                      ),
                    ),
                  TodayComparisonSection(
                    dateKey: dateKey,
                    slots: snapshot.comparisonSlots,
                    todos: snapshot.todos,
                    isToday: isToday,
                  ),
                  TodayStatsCard(
                    plannedMinutes: snapshot.plannedMinutes,
                    actualMinutes: snapshot.actualMinutes,
                    focusMinutes: snapshot.focusMinutes,
                    plannedSegments: snapshot.plannedSegmentCount,
                    actualSegments: snapshot.actualSegmentCount,
                  ),
                  SectionCard(
                    title: AppCopy.journalNotesTitle,
                    subtitle: AppCopy.journalNotesSubtitle,
                    child: TextField(
                      controller: _notesController,
                      minLines: 1,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: AppCopy.journalNotesHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.rule),
                        ),
                      ),
                      onChanged: (v) => _saveNotesDebounced(dateKey, v),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _scheduleTodo(String dateKey, TodoItem item) async {
    final task = item.content.trim();
    if (task.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('先写下待办内容，再安排时间'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final result = await showScheduleSheet(context, taskName: task);
    if (result == null) return;
    await ref.read(journalRepositoryProvider).createPlannedBlock(
          date: dateKey,
          startTime: result.startTime,
          endTime: result.endTime,
          content: result.content,
          linkedTodoId: item.id,
        );
    ref.invalidate(journalSnapshotProvider);
    GentleFeedback.lightTap();
  }

  void _openTodoActions(String dateKey, TodoItem item) {
    showTodoActionSheet(
      context,
      item: item,
      onSchedule: () => _scheduleTodo(dateKey, item),
      onFocus: () {
        GentleFeedback.lightTap();
        navigateToFocusTab(ref, task: item.content);
      },
      onComplete: () => _toggleTodo(item),
      onDelete: () => _deleteTodo(item),
    );
  }

  Widget _buildTodoRow(String dateKey, TodoItem item) {
    final controller = _controllerForTodo(item);
    final showHint = _showFirstTodoHint && _firstTodoHintItemId == item.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _openTodoActions(dateKey, item),
            child: Row(
            children: [
              Checkbox(
                value: item.completed,
                onChanged: (_) => _toggleTodo(item),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: 15,
                    decoration:
                        item.completed ? TextDecoration.lineThrough : null,
                    color: item.completed ? AppTheme.inkFaint : AppTheme.ink,
                  ),
                  decoration:
                      const InputDecoration(hintText: AppCopy.journalTodoHint),
                  onChanged: (v) => _persistTodo(dateKey, item, v),
                ),
              ),
              TextButton(
                onPressed: () => _scheduleTodo(dateKey, item),
                child: const Text(AppCopy.journalTodoArrange),
              ),
            ],
          ),
          ),
          if (showHint)
            FirstTodoHint(
              onDismissed: () {
                if (mounted) {
                  setState(() {
                    _showFirstTodoHint = false;
                    _firstTodoHintItemId = null;
                  });
                }
              },
            ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.displayDate,
    required this.weekday,
    this.attendanceHint,
  });

  final String displayDate;
  final String weekday;
  final String? attendanceHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayDate,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            weekday,
            style: const TextStyle(fontSize: 13, color: AppTheme.inkMuted),
          ),
          if (attendanceHint != null) ...[
            const SizedBox(height: 4),
            Text(
              attendanceHint!,
              style: const TextStyle(fontSize: 12, color: AppTheme.inkFaint),
            ),
          ],
        ],
      ),
    );
  }
}