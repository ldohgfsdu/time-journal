import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';
import '../features/shell/main_shell.dart';

class TimeJournalApp extends ConsumerStatefulWidget {
  const TimeJournalApp({super.key});

  @override
  ConsumerState<TimeJournalApp> createState() => _TimeJournalAppState();
}

class _TimeJournalAppState extends ConsumerState<TimeJournalApp> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时间管理手账',
      theme: AppTheme.light(),
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShell(),
    );
  }
}
