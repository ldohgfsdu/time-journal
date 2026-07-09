import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        vertical: 8,
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.journalStatsTitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.muted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          _StatLine(
            AppCopy.journalStatsPlanned(
              plannedSegments,
              AppCopy.fmtDuration(plannedMinutes),
            ),
          ),
          const SizedBox(height: 6),
          _StatLine(
            AppCopy.journalStatsActual(
              actualSegments,
              AppCopy.fmtDuration(actualMinutes),
            ),
          ),
          const SizedBox(height: 6),
          _StatLine(
            AppCopy.journalStatsFocus(AppCopy.fmtFocusDuration(focusSeconds)),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppTheme.body,
        height: 1.45,
      ),
    );
  }
}
