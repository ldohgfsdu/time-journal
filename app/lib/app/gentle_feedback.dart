import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/pomodoro/providers/pomodoro_provider.dart';
import 'copy.dart';
import 'theme.dart';

/// 温和陪伴式交互反馈：轻触觉 + 短文案，无惩罚感
class GentleFeedback {
  GentleFeedback._();

  static void lightTap() => HapticFeedback.lightImpact();

  static void celebrate() => HapticFeedback.mediumImpact();

  static void sleepCheckIn(BuildContext context, String message) {
    lightTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<void> focusCompletedSheet(
    BuildContext context, {
    required PendingFocusCompletion pending,
    required Future<void> Function({String? note}) onRecord,
    required VoidCallback onStartBreak,
    required VoidCallback onDismiss,
  }) async {
    celebrate();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final noteController = TextEditingController();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                AppCopy.focusCompleteTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                AppCopy.focusCompleteDetail(pending.minutes, pending.task),
                style: const TextStyle(fontSize: 15, color: AppTheme.inkMuted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await onRecord();
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppCopy.focusCompleteRecorded),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text(AppCopy.focusCompleteRecord),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final note = noteController.text.trim();
                  await onRecord(note: note.isEmpty ? null : note);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text(AppCopy.focusCompleteNote),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  onStartBreak();
                },
                icon: const Icon(Icons.self_improvement_rounded, size: 18),
                label: const Text(AppCopy.focusStartBreakButton),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: AppCopy.focusCompleteHint,
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        );
      },
    );
    onDismiss();
  }

  static void focusStarted() => lightTap();
}