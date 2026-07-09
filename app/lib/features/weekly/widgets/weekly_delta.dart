import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';

/// 与上周对比 —— 中性灰 + 箭头，无红涨绿跌
class WeeklyDelta extends StatelessWidget {
  const WeeklyDelta({
    super.key,
    required this.delta,
    required this.hasActivity,
    this.formatAbs,
  });

  final int? delta;
  final bool hasActivity;
  /// 格式化绝对差值；默认直接 toString（适合「天数」）。
  final String Function(int absValue)? formatAbs;

  @override
  Widget build(BuildContext context) {
    if (delta == null || delta == 0) {
      return Text(
        hasActivity ? AppCopy.weeklyDeltaFlat : AppCopy.weeklyDeltaEmpty,
        style: const TextStyle(fontSize: 12, color: AppTheme.inkFaint),
      );
    }
    final up = delta! > 0;
    final amount = formatAbs?.call(delta!.abs()) ?? '${delta!.abs()}';
    return Text(
      AppCopy.weeklyDeltaCompare(up, amount),
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.inkMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}