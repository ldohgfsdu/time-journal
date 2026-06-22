import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../data/local/database.dart';
import 'providers/journal_providers.dart';
import 'widgets/section_card.dart';
import 'widgets/time_block_editor.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final Map<int, TextEditingController> _todoControllers = {};
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _availableController = TextEditingController();
  Timer? _notesDebounce;
  Timer? _availableDebounce;
  String? _loadedNotesDate;

  @override
  void dispose() {
    _notesDebounce?.cancel();
    _availableDebounce?.cancel();
    _notesController.dispose();
    _availableController.dispose();
    for (final c in _todoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _shiftDate(int days) {
    final current = ref.read(selectedDateProvider);
    ref.read(selectedDateProvider.notifier).state = current.add(Duration(days: days));
  }

  Future<void> _persistTodo(TodoItem item, String content) async {
    await ref.read(journalRepositoryProvider).updateTodo(item.copyWith(content: content));
    ref.invalidate(journalSnapshotProvider);
  }

  Future<void> _toggleTodo(TodoItem item) async {
    await ref.read(journalRepositoryProvider).updateTodo(item.copyWith(completed: !item.completed));
    ref.invalidate(journalSnapshotProvider);
  }

  Future<void> _saveNotesDebounced(String date, String notes) async {
    _notesDebounce?.cancel();
    _notesDebounce = Timer(const Duration(milliseconds: 500), () async {
      await ref.read(journalRepositoryProvider).saveNotes(date, notes);
    });
  }

  Future<void> _saveAvailableDebounced(String date, String text) async {
    _availableDebounce?.cancel();
    _availableDebounce = Timer(const Duration(milliseconds: 500), () async {
      final minutes = int.tryParse(text.trim());
      await ref.read(journalRepositoryProvider).saveAvailableMinutes(date, minutes);
      ref.invalidate(journalSnapshotProvider);
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
    final weekday = DateFormat('EEEE', 'zh_CN').format(date);
    final displayDate = DateFormat('yyyy年M月d日').format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('时间管理手账'),
        actions: [
          IconButton(onPressed: () => _shiftDate(-1), icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () => _shiftDate(1), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (snapshot) {
          if (_loadedNotesDate != dateKey) {
            _loadedNotesDate = dateKey;
            _notesController.text = snapshot.journal.notes;
            _availableController.text = snapshot.journal.availableStudyMinutes?.toString() ?? '';
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(journalSnapshotProvider),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('$displayDate  $weekday', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                SectionCard(
                  title: '待办事项',
                  trailing: TextButton(
                    onPressed: () async {
                      await ref.read(journalRepositoryProvider).addTodo(dateKey);
                      ref.invalidate(journalSnapshotProvider);
                    },
                    child: const Text('+ 添加'),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < snapshot.todos.length; i++)
                        _buildTodoRow(snapshot.todos[i], i),
                      if (snapshot.todos.isEmpty)
                        const Text('写下今天所有待办，再按重要性排序', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildTimeSection(dateKey, '计划完成', snapshot.plannedBlocks, 'planned')),
                        const VerticalDivider(width: 1),
                        Expanded(child: _buildTimeSection(dateKey, '实际完成', snapshot.actualBlocks, 'actual')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('计划学习时间：${_formatMinutes(snapshot.plannedMinutes)}'),
                      const SizedBox(width: 16),
                      Text('实际学习时间：${_formatMinutes(snapshot.actualMinutes)}'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Text('可用学习时间：'),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _availableController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '分钟'),
                          onChanged: (v) => _saveAvailableDebounced(dateKey, v),
                        ),
                      ),
                      const Text(' 分钟'),
                    ],
                  ),
                ),
                const Divider(height: 24),
                SectionCard(
                  title: '备注',
                  child: TextField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: null,
                    decoration: const InputDecoration(hintText: '记录感受、反思或明日提示...'),
                    onChanged: (v) => _saveNotesDebounced(dateKey, v),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodoRow(TodoItem item, int index) {
    final controller = _controllerForTodo(item);
    final label = String.fromCharCode(0x2460 + index.clamp(0, 19));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: item.completed, onChanged: (_) => _toggleTodo(item)),
          Text(label, style: const TextStyle(fontSize: 16, height: 2)),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: null,
              style: TextStyle(
                decoration: item.completed ? TextDecoration.lineThrough : null,
                color: item.completed ? Colors.black45 : AppTheme.ink,
              ),
              decoration: const InputDecoration(hintText: '输入待办...'),
              onChanged: (v) => _persistTodo(item, v),
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(journalRepositoryProvider).removeTodo(item.id);
              _todoControllers.remove(item.id)?.dispose();
              ref.invalidate(journalSnapshotProvider);
            },
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(String dateKey, String title, List<TimeBlock> blocks, String source) {
    final repo = ref.read(journalRepositoryProvider);
    return SectionCard(
      title: title,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (source == 'actual')
            TextButton(
              onPressed: () async {
                await repo.copyPlannedToActual(dateKey);
                ref.invalidate(journalSnapshotProvider);
              },
              child: const Text('从计划复制', style: TextStyle(fontSize: 12)),
            ),
          TextButton(
            onPressed: () async {
              await repo.addBlock(dateKey, source);
              ref.invalidate(journalSnapshotProvider);
            },
            child: const Text('+ 时段', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final block in blocks)
            TimeBlockEditor(
              block: block,
              onChanged: (updated) async {
                await repo.updateBlock(updated);
                ref.invalidate(journalSnapshotProvider);
              },
              onDelete: () async {
                await repo.removeBlock(block.id);
                ref.invalidate(journalSnapshotProvider);
              },
            ),
          if (blocks.isEmpty)
            Text('点击 + 时段添加$title内容', style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}分钟';
    if (m == 0) return '${h}小时';
    return '${h}小时${m}分钟';
  }
}
