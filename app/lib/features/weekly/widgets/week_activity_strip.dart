import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../data/models/weekly_summary.dart';

enum WeekStripMetric { journal, focus, sleep }

/// 节奏热力图 —— 方块矩阵，一眼看清哪天有记录
class WeekActivityStrip extends StatelessWidget {
  const WeekActivityStrip({
    super.key,
    required this.label,
    required this.days,
    required this.metric,
  });

  final String label;
  final List<DayActivity> days;
  final WeekStripMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.inkMuted),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      Expanded(
                        child: Center(
                          child: _HeatCell(
                            day: days[i],
                            metric: metric,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeekHeatmapHeader extends StatelessWidget {
  const WeekHeatmapHeader({super.key, required this.days});

  final List<DayActivity> days;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, bottom: 6),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: Text(
                days[i].weekdayLabel.replaceAll('周', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppTheme.inkFaint),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.day, required this.metric});

  final DayActivity day;
  final WeekStripMetric metric;

  @override
  Widget build(BuildContext context) {
    final active = _isActive();
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: active ? _activeColor() : AppTheme.card,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active
              ? _activeColor().withValues(alpha: 0.8)
              : AppTheme.rule,
        ),
      ),
      child: active
          ? null
          : const Center(
              child: Text(
                '○',
                style: TextStyle(fontSize: 10, color: AppTheme.inkFaint),
              ),
            ),
    );
  }

  bool _isActive() {
    switch (metric) {
      case WeekStripMetric.journal:
        return day.hasJournal;
      case WeekStripMetric.focus:
        return day.focusMinutes > 0;
      case WeekStripMetric.sleep:
        return day.earlySleep;
    }
  }

  Color _activeColor() {
    switch (metric) {
      case WeekStripMetric.journal:
        return AppTheme.tomato.withValues(alpha: 0.45);
      case WeekStripMetric.focus:
        return AppTheme.tomato.withValues(alpha: 0.65);
      case WeekStripMetric.sleep:
        return AppTheme.sleepBlue.withValues(alpha: 0.5);
    }
  }
}