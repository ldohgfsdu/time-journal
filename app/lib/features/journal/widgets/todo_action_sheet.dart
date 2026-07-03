import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';
import '../../../data/local/database.dart';

Future<void> showTodoActionSheet(
  BuildContext context, {
  required TodoItem item,
  required VoidCallback onSchedule,
  required VoidCallback onFocus,
  required VoidCallback onComplete,
  required VoidCallback onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final title = item.content.trim().isEmpty
          ? AppCopy.journalTodoHint
          : item.content.trim();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.schedule_rounded,
                label: AppCopy.todoActionSchedule,
                onTap: () {
                  Navigator.pop(ctx);
                  onSchedule();
                },
              ),
              _ActionTile(
                icon: Icons.timer_outlined,
                label: AppCopy.todoActionFocus,
                onTap: () {
                  Navigator.pop(ctx);
                  onFocus();
                },
              ),
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: AppCopy.todoActionComplete,
                onTap: () {
                  Navigator.pop(ctx);
                  onComplete();
                },
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: AppCopy.todoActionDelete,
                color: AppTheme.danger,
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.ink,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      onTap: onTap,
    );
  }
}