import '../local/database.dart';

enum SlotStatus { match, pending, changed, unplanned }

class ComparisonSlot {
  const ComparisonSlot({
    this.planned,
    this.actual,
    this.orphanActual = false,
  });

  final TimeBlock? planned;
  final TimeBlock? actual;
  final bool orphanActual;

  bool get hasPlan => planned != null && planned!.content.trim().isNotEmpty;

  String get taskTitle {
    if (hasPlan) return planned!.content.trim();
    if (actual != null && actual!.content.trim().isNotEmpty) {
      return actual!.content.trim();
    }
    return '';
  }

  String get timeRange {
    final block = planned ?? actual;
    if (block == null) return '';
    return '${block.startTime} - ${block.endTime}';
  }

  SlotStatus get status {
    if (orphanActual || planned == null) return SlotStatus.unplanned;
    if (actual == null || actual!.content.trim().isEmpty) return SlotStatus.pending;
    final sameContent = actual!.content.trim() == planned!.content.trim();
    final sameTime = actual!.startTime == planned!.startTime && actual!.endTime == planned!.endTime;
    if (sameContent && sameTime) return SlotStatus.match;
    return SlotStatus.changed;
  }

  String get actualLabel {
    if (actual == null || actual!.content.trim().isEmpty) {
      return '未记录';
    }
    return actual!.content.trim();
  }
}