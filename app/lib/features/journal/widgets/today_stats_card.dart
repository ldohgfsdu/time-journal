import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';

class TodayStatsCard extends StatelessWidget {
  const TodayStatsCard({
    super.key,
    required this.plannedMinutes,
    required this.actualMinutes,
    required this.focusSeconds,
    required this.plannedSegments,
    required this.actualSegments,
  });

  final int plannedMinutes;
  final int actualMinutes;
  final int focusSeconds;
  final int plannedSegments;
  final int actualSegments;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: 6,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppCopy.journalStatsTitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            AppCopy.journalStatsPlanned(
              plannedSegments,
              AppCopy.fmtDuration(plannedMinutes),
            ),
            style: const TextStyle(fontSize: 14, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 4),
          Text(
            AppCopy.journalStatsActual(
              actualSegments,
              AppCopy.fmtDuration(actualMinutes),
            ),
            style: const TextStyle(fontSize: 14, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 4),
          Text(
            AppCopy.journalStatsFocus(AppCopy.fmtFocusDuration(focusSeconds)),
            style: const TextStyle(fontSize: 14, color: AppTheme.inkMuted),
          ),
        ],
      ),
    );
  }
}