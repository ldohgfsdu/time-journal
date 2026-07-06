import 'package:flutter/material.dart';
import 'theme.dart';

/// Centralized time picker helper — all showTimePicker calls go through here.
///
/// Uses dial mode to avoid system keyboard input.
Future<TimeOfDay?> safeShowTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  required String helpText,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
    initialEntryMode: TimePickerEntryMode.dial,
    barrierColor: AppTheme.barrier,
    builder: (context, child) => Theme(
      data: AppTheme.light().copyWith(
        timePickerTheme: AppTheme.light().timePickerTheme.copyWith(
          backgroundColor: AppTheme.paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          dialBackgroundColor: AppTheme.card,
          dialHandColor: AppTheme.tomato,
          dialTextColor: AppTheme.ink,
          hourMinuteTextColor: AppTheme.ink,
          dayPeriodTextColor: AppTheme.ink,
          entryModeIconColor: AppTheme.inkMuted,
          hourMinuteColor: AppTheme.tomatoSoft,
          dayPeriodColor: AppTheme.tomatoSoft,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppTheme.tomato),
        ),
      ),
      child: child!,
    ),
  );
}
