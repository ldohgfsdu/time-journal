import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/app/widgets/time_wheel_row.dart';

void main() {
  group('roundMinuteToStep', () {
    test('rounds to 5 minutes', () {
      expect(roundMinuteToStep(2), 0);
      expect(roundMinuteToStep(3), 5);
      expect(roundMinuteToStep(58), 0);
    });
  });
}