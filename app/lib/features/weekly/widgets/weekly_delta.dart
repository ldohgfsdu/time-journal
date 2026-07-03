import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';

/// 与上周对比 —— 中性灰 + 箭头，无红涨绿跌
class WeeklyDelta extends StatelessWidget {
  const WeeklyDelta({
    super.key,
    required this.delta,
    required this.hasActivity,
  });

  final int? delta;
  final bool hasActivity;

  @override
  Widget build(BuildContext context) {
    if (delta == null || delta == 0) {
      return Text(
        hasActivity ? AppCopy.weeklyDeltaFlat : AppCopy.weeklyDeltaEmpty,
        style: const TextStyle(fontSize: 12, color: AppTheme.inkFaint),
      );
    }
    final up = delta! > 0;
    return Text(
      AppCopy.weeklyDeltaCompare(up, delta!.abs()),
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.inkMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}