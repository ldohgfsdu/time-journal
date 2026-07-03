import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// 本周早睡进度 —— 克制点状，替代星星墙
class SleepWeekDots extends StatelessWidget {
  const SleepWeekDots({
    super.key,
    required this.litCount,
    this.total = 7,
  });

  final int litCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final lit = i < litCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lit
                  ? AppTheme.sleepBlue.withValues(alpha: 0.75)
                  : AppTheme.sleepBlue.withValues(alpha: 0.18),
              border: Border.all(
                color: lit
                    ? AppTheme.sleepBlue.withValues(alpha: 0.5)
                    : AppTheme.sleepBlue.withValues(alpha: 0.28),
              ),
            ),
          ),
        );
      }),
    );
  }
}