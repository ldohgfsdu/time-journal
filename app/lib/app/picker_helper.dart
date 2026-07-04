import 'package:flutter/material.dart';
import 'theme.dart';

/// Centralized time picker helper — all showTimePicker calls go through here.
///
/// Uses [TimePickerEntryMode.input] to reduce dial-animation jank on device.
Future<TimeOfDay?> safeShowTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required String helpText,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
    initialEntryMode: TimePickerEntryMode.input,
    builder: (context, child) => Theme(
      data: AppTheme.light().copyWith(
        colorScheme: AppTheme.light().colorScheme.copyWith(
              secondary: AppTheme.tomato,
            ),
        dialogTheme: const DialogThemeData(
          barrierColor: Colors.black54,
          backgroundColor: AppTheme.paper,
        ),
      ),
      child: child!,
    ),
  );
}
