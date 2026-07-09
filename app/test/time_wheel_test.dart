import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_journal/app/widgets/time_wheel_row.dart';

void main() {
  group('roundMinuteToStep', () {
    test('step 1 keeps exact minutes', () {
      expect(roundMinuteToStep(2, step: 1), 2);
      expect(roundMinuteToStep(59, step: 1), 59);
    });

    test('rounds to 5 minutes when step is 5', () {
      expect(roundMinuteToStep(2, step: 5), 0);
      expect(roundMinuteToStep(3, step: 5), 5);
      expect(roundMinuteToStep(58, step: 5), 0);
    });
  });

  group('tryParseTimeOfDay', () {
    test('parses HH:mm', () {
      final t = tryParseTimeOfDay('14:30');
      expect(t, isNotNull);
      expect(t!.hour, 14);
      expect(t.minute, 30);
    });

    test('parses fullwidth colon', () {
      final t = tryParseTimeOfDay('9：05');
      expect(t, isNotNull);
      expect(t!.hour, 9);
      expect(t.minute, 5);
    });

    test('rejects invalid', () {
      expect(tryParseTimeOfDay('25:00'), isNull);
      expect(tryParseTimeOfDay('12:99'), isNull);
      expect(tryParseTimeOfDay('abc'), isNull);
    });
  });

  testWidgets('TimeWheelRow lays out with visible height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimeWheelRow(
            value: const TimeOfDay(hour: 14, minute: 30),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final size = tester.getSize(find.byType(TimeWheelRow));
    expect(size.height, greaterThan(120));
  });
}
