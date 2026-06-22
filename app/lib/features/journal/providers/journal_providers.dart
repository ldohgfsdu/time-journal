import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/repositories/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(databaseProvider));
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedDateKeyProvider = Provider<String>((ref) {
  final date = ref.watch(selectedDateProvider);
  return DateFormat('yyyy-MM-dd').format(date);
});

final journalSnapshotProvider = FutureProvider.autoDispose<JournalSnapshot>((ref) async {
  final date = ref.watch(selectedDateKeyProvider);
  return ref.watch(journalRepositoryProvider).load(date);
});
