import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/local/database.dart';
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
  final repository = ref.watch(journalRepositoryProvider);
  await repository.purgeEmptyRecords(date);
  return repository.load(date);
});

/// 今日待办（有内容的），供专注模块快捷带入
final todayTodosProvider = FutureProvider.autoDispose<List<TodoItem>>((ref) async {
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final repository = ref.watch(journalRepositoryProvider);
  await repository.purgeEmptyRecords(date);
  final snapshot = await repository.load(date);
  return snapshot.todos.where((t) => t.content.trim().isNotEmpty).toList();
});
