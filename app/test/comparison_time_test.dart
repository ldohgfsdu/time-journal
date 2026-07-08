import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/core/utils/comparison_time.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/models/comparison_slot.dart';

TimeBlock _plan(String start, String end, {String content = '学习'}) {
  return TimeBlock(
    id: 1,
    journalDate: '2026-07-08',
    startTime: start,
    endTime: end,
    content: content,
    source: 'planned',
    sortOrder: 0,
  );
}

ComparisonSlot _slot(String start, String end) =>
    ComparisonSlot(planned: _plan(start, end));

void main() {
  group('slotTimePhaseForBlock', () {
    test('current inside range', () {
      expect(
        slotTimePhaseForBlock(_plan('09:00', '10:00'), 9 * 60 + 30),
        SlotTimePhase.current,
      );
    });

    test('past after end', () {
      expect(
        slotTimePhaseForBlock(_plan('09:00', '10:00'), 10 * 60),
        SlotTimePhase.past,
      );
    });

    test('future before start', () {
      expect(
        slotTimePhaseForBlock(_plan('09:00', '10:00'), 8 * 60),
        SlotTimePhase.future,
      );
    });
  });

  group('hasCurrentPlannedSlot', () {
    test('true when one block covers now', () {
      final slots = [_slot('09:00', '10:00'), _slot('11:00', '12:00')];
      expect(hasCurrentPlannedSlot(slots, 9 * 60 + 15), isTrue);
    });

    test('false in gap between blocks', () {
      final slots = [_slot('09:00', '10:00'), _slot('11:00', '12:00')];
      expect(hasCurrentPlannedSlot(slots, 10 * 60 + 30), isFalse);
    });
  });

  group('orderComparisonSlotsForToday', () {
    test('moves current slot to front', () {
      final slots = [
        _slot('09:00', '10:00'),
        _slot('10:00', '11:00'),
        _slot('14:00', '15:00'),
      ];
      final ordered = orderComparisonSlotsForToday(slots, 10 * 60 + 15);
      expect(ordered.first.planned!.startTime, '10:00');
    });
  });

  group('suggestCatchUpWindow', () {
    test('from last ended plan to now', () {
      final slots = [_slot('09:00', '10:00')];
      final window = suggestCatchUpWindow(slots: slots, nowMinutes: 10 * 60 + 20);
      expect(window.start, const TimeOfDay(hour: 10, minute: 0));
      expect(window.end, const TimeOfDay(hour: 10, minute: 20));
    });

    test('defaults to last 30 minutes when no prior plan', () {
      final window = suggestCatchUpWindow(slots: const [], nowMinutes: 16 * 60);
      expect(window.start, const TimeOfDay(hour: 15, minute: 30));
      expect(window.end, const TimeOfDay(hour: 16, minute: 0));
    });
  });
}