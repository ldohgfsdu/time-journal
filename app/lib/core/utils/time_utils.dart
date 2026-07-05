import '../../data/local/database.dart';

int parseTime(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

int sumBlockMinutes(List<TimeBlock> blocks) {
  var total = 0;
  for (final b in blocks) {
    if (b.content.trim().isEmpty) continue;
    final start = parseTime(b.startTime);
    final end = parseTime(b.endTime);
    if (end > start) total += end - start;
  }
  return total;
}
