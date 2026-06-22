import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_journal/app/app.dart';
import 'package:time_journal/data/local/database.dart';
import 'package:time_journal/data/local/database_provider.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const TimeJournalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('时间管理手账'), findsOneWidget);
    expect(find.text('手账'), findsOneWidget);
    expect(find.text('专注'), findsOneWidget);
    expect(find.text('睡眠'), findsOneWidget);
  });
}
