import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Rounds [minute] to nearest step (0–59).
int roundMinuteToStep(int minute, {int step = 5}) {
  if (step <= 1) return minute.clamp(0, 59);
  final rounded = ((minute + step ~/ 2) ~/ step) * step;
  return rounded >= 60 ? 0 : rounded;
}

/// Hand-journal style hour : minute wheels (24h, 5-minute steps).
class TimeWheelRow extends StatelessWidget {
  const TimeWheelRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.minuteStep = 5,
  });

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final int minuteStep;

  @override
  Widget build(BuildContext context) {
    final minuteSlots = List<int>.generate(
      60 ~/ minuteStep,
      (i) => i * minuteStep,
    );
    final rounded = roundMinuteToStep(value.minute, step: minuteStep);
    var minuteIndex = minuteSlots.indexOf(rounded);
    if (minuteIndex < 0) minuteIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.rule),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: value.hour,
              ),
              itemExtent: 36,
              magnification: 1.08,
              squeeze: 1.05,
              useMagnifier: true,
              onSelectedItemChanged: (hour) {
                onChanged(TimeOfDay(hour: hour, minute: minuteSlots[minuteIndex]));
              },
              children: List.generate(
                24,
                (h) => Center(
                  child: Text(
                    h.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.inkMuted,
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: minuteIndex,
              ),
              itemExtent: 36,
              magnification: 1.08,
              squeeze: 1.05,
              useMagnifier: true,
              onSelectedItemChanged: (index) {
                onChanged(
                  TimeOfDay(hour: value.hour, minute: minuteSlots[index]),
                );
              },
              children: minuteSlots
                  .map(
                    (m) => Center(
                      child: Text(
                        m.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}