import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/gentle_feedback.dart';
import '../../../app/theme.dart';
import '../../../data/local/database.dart';
import 'todo_pick_chips.dart';

class TimeBlockEditor extends StatefulWidget {
  const TimeBlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
    this.todos = const [],
    this.showTodoPicker = false,
    this.unavailableTodoIds = const {},
  });

  final TimeBlock block;
  final ValueChanged<TimeBlock> onChanged;
  final VoidCallback onDelete;
  final List<TodoItem> todos;
  final bool showTodoPicker;
  final Set<int> unavailableTodoIds;

  @override
  State<TimeBlockEditor> createState() => _TimeBlockEditorState();
}

class _TimeBlockEditorState extends State<TimeBlockEditor> {
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.block.content);
  }

  @override
  void didUpdateWidget(TimeBlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.id != widget.block.id ||
        (oldWidget.block.content != widget.block.content &&
            _contentController.text != widget.block.content)) {
      _contentController.text = widget.block.content;
    }
  }

  void _pickTodo(TodoItem todo) {
    GentleFeedback.lightTap();
    _contentController.text = todo.content;
    widget.onChanged(widget.block.copyWith(
      content: todo.content,
      linkedTodoId: Value(todo.id),
    ));
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? widget.block.startTime : widget.block.endTime).split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.tomato),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    widget.onChanged(widget.block.copyWith(
      startTime: isStart ? value : widget.block.startTime,
      endTime: isStart ? widget.block.endTime : value,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.paper.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TimeChip(label: widget.block.startTime, onTap: () => _pickTime(true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('—', style: TextStyle(color: AppTheme.inkFaint)),
              ),
              _TimeChip(label: widget.block.endTime, onTap: () => _pickTime(false)),
              const Spacer(),
              InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, size: 18, color: AppTheme.inkFaint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            minLines: 2,
            maxLines: null,
            style: const TextStyle(fontSize: 15, height: 1.5),
            decoration: const InputDecoration(
              hintText: AppCopy.journalBlockHint,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.rule),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => widget.onChanged(
              widget.block.copyWith(content: v, linkedTodoId: const Value(null)),
            ),
          ),
          if (widget.showTodoPicker)
            TodoPickChips(
              label: AppCopy.journalBlockPickTodo,
              todos: widget.todos,
              selectedId: widget.block.linkedTodoId,
              disabledIds: widget.unavailableTodoIds,
              onPick: _pickTodo,
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.tomatoSoft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.tomato,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}