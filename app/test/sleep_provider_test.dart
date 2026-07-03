import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/features/sleep/providers/sleep_provider.dart';

void main() {
  group('calculateSleepScore', () {
    test('gives full score within 15 minutes of bedtime target', () {
      final score = calculateSleepScore(
        targetBedtime: '23:00',
        actualBedtime: DateTime(2026, 6, 25, 23, 12),
      );

      expect(score, 10);
    });

    test('gives partial score within 30 minutes of bedtime target', () {
      final score = calculateSleepScore(
        targetBedtime: '23:00',
        actualBedtime: DateTime(2026, 6, 25, 23, 25),
      );

      expect(score, 5);
    });

    test('gives zero when bedtime is more than 30 minutes late', () {
      final score = calculateSleepScore(
        targetBedtime: '23:00',
        actualBedtime: DateTime(2026, 6, 25, 23, 31),
      );

      expect(score, 0);
    });
  });
}
