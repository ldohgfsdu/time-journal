import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/models/weekly_summary.dart';
import '../../../data/repositories/weekly_repository.dart';

final weeklyRepositoryProvider = Provider<WeeklyRepository>((ref) {
  return WeeklyRepository(ref.watch(databaseProvider));
});

final selectedWeekMondayProvider = StateProvider<DateTime>((ref) {
  return WeeklyRepository.mondayOf(DateTime.now());
});

final weeklySummaryProvider =
    FutureProvider.autoDispose<WeeklySummary>((ref) async {
  final monday = ref.watch(selectedWeekMondayProvider);
  return ref.watch(weeklyRepositoryProvider).loadWeek(monday);
});