import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/notification_service.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await LocalNotificationService.instance.initialize();
  } catch (e, stack) {
    dev.log('Notification init failed: $e', name: 'main', error: e, stackTrace: stack);
  }
  runApp(const ProviderScope(child: TimeJournalApp()));
}
