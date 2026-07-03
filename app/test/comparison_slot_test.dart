import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/models/comparison_slot.dart';

TimeBlock _planned({String content = '背单词'}) => TimeBlock(
      id: 1,
      journalDate: '2026-07-04',
      startTime: '09:00',
      endTime: '10:00',
      content: content,
      source: 'planned',
      sortOrder: 0,
    );

TimeBlock _actual({String content = '背单词'}) => TimeBlock(
      id: 2,
      journalDate: '2026-07-04',
      startTime: '09:00',
      endTime: '10:00',
      content: content,
      source: 'actual',
      sortOrder: 0,
    );

void main() {
  group('ComparisonSlot.status', () {
    test('returns pending when actual is null', () {
      final slot = ComparisonSlot(
        planned: _planned(),
        actual: null,
      );
      expect(slot.status, SlotStatus.pending);
    });

    test('returns pending when actual content is empty string', () {
      final slot = ComparisonSlot(
        planned: _planned(),
        actual: _actual(content: ''),
      );
      expect(slot.status, SlotStatus.pending);
    });

    test('returns pending when actual content is whitespace only', () {
      final slot = ComparisonSlot(
        planned: _planned(),
        actual: _actual(content: '   '),
      );
      expect(slot.status, SlotStatus.pending);
    });

    test('returns match when actual content equals planned content', () {
      final slot = ComparisonSlot(
        planned: _planned(content: '背单词'),
        actual: _actual(content: '背单词'),
      );
      expect(slot.status, SlotStatus.match);
    });

    test('returns match after trimming both planned and actual content', () {
      final slot = ComparisonSlot(
        planned: _planned(content: ' 背单词 '),
        actual: _actual(content: ' 背单词 '),
      );
      expect(slot.status, SlotStatus.match);
    });

    test(
        'returns match when differing only in whitespace (both sides trim)',
        () {
      final slot = ComparisonSlot(
        planned: _planned(content: '背单词'),
        actual: _actual(content: '  背单词  '),
      );
      expect(slot.status, SlotStatus.match);
    });

    test('returns changed when actual content differs from planned', () {
      final slot = ComparisonSlot(
        planned: _planned(content: '背单词'),
        actual: _actual(content: '复习高数'),
      );
      expect(slot.status, SlotStatus.changed);
    });

    test('returns unplanned when planned is null and actual is present', () {
      final slot = ComparisonSlot(
        planned: null,
        actual: _actual(),
      );
      expect(slot.status, SlotStatus.unplanned);
    });

    test('returns unplanned when planned is null and actual is null', () {
      const slot = ComparisonSlot(
        planned: null,
        actual: null,
      );
      expect(slot.status, SlotStatus.unplanned);
    });

    test('returns unplanned when orphanActual is true, regardless of data',
        () {
      final slot = ComparisonSlot(
        planned: _planned(content: '背单词'),
        actual: _actual(content: '背单词'),
        orphanActual: true,
      );
      expect(slot.status, SlotStatus.unplanned);
    });

    test(
        'orphanActual takes precedence over match even with matching content',
        () {
      final slot = ComparisonSlot(
        planned: _planned(content: '背单词'),
        actual: _actual(content: '背单词'),
        orphanActual: true,
      );
      expect(slot.status, SlotStatus.unplanned);
    });

    test('unplanned when planned is null takes precedence over pending', () {
      final slot = ComparisonSlot(
        planned: null,
        actual: null,
      );
      // planned == null → unplanned (not pending, despite no actual content)
      expect(slot.status, SlotStatus.unplanned);
    });
  });
}
