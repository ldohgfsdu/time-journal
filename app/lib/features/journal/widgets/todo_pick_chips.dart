import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';
import '../../../data/local/database.dart';

/// 从待办列表轻点带入任务名 —— 计划时段 / 专注模块共用
class TodoPickChips extends StatelessWidget {
  const TodoPickChips({
    super.key,
    required this.label,
    required this.todos,
    required this.onPick,
    this.selectedId,
    this.disabledIds = const {},
  });

  final String label;
  final List<TodoItem> todos;
  final ValueChanged<TodoItem> onPick;
  final int? selectedId;
  /// 已在其他时段排期的待办 —— 置灰不可点，防止重复安排
  final Set<int> disabledIds;

  @override
  Widget build(BuildContext context) {
    final available = todos.where((t) => t.content.trim().isNotEmpty).toList();
    if (available.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.inkFaint),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: available.map((todo) {
            final selected = selectedId == todo.id;
            final disabled = disabledIds.contains(todo.id);
            final text = todo.content.trim();
            final display =
                text.length > 12 ? '${text.substring(0, 12)}…' : text;

            final chip = Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppTheme.tomato.withValues(alpha: 0.5)
                      : disabled
                          ? AppTheme.rule.withValues(alpha: 0.6)
                          : AppTheme.rule,
                ),
              ),
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppTheme.tomato
                      : disabled
                          ? AppTheme.inkFaint
                          : AppTheme.inkMuted,
                  decoration: disabled ? TextDecoration.lineThrough : null,
                  decorationColor: AppTheme.inkFaint,
                ),
              ),
            );

            if (disabled) {
              return Tooltip(
                message: AppCopy.journalTodoChipScheduled,
                child: Material(
                  color: AppTheme.paperDeep.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  child: chip,
                ),
              );
            }

            return Material(
              color: selected
                  ? AppTheme.tomatoSoft
                  : AppTheme.paperDeep.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => onPick(todo),
                borderRadius: BorderRadius.circular(16),
                child: chip,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}