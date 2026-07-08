import 'package:flutter/material.dart';

import '../../data/local/database.dart';
import '../../data/models/comparison_slot.dart';
import 'time_utils.dart';

enum SlotTimePhase { future, current, past }

SlotTimePhase slotTimePhaseForBlock(TimeBlock plan, int nowMinutes) {
  final start = parseTime(plan.startTime);
  final end = parseTime(plan.endTime);
  if (nowMinutes < start) return SlotTimePhase.future;
  if (nowMinutes >= end) return SlotTimePhase.past;
  return SlotTimePhase.current;
}

bool hasCurrentPlannedSlot(List<ComparisonSlot> slots, int nowMinutes) {
  for (final slot in slots) {
    final plan = slot.planned;
    if (plan == null || plan.content.trim().isEmpty) continue;
    if (slotTimePhaseForBlock(plan, nowMinutes) == SlotTimePhase.current) {
      return true;
    }
  }
  return false;
}

/// 今日对照列表：有「现在」时段时把它排到最前，方便一眼看到。
List<ComparisonSlot> orderComparisonSlotsForToday(
  List<ComparisonSlot> slots,
  int nowMinutes,
) {
  final visible = slots.where((s) => s.hasPlan || s.orphanActual).toList();
  var currentIndex = -1;
  for (var i = 0; i < visible.length; i++) {
    final plan = visible[i].planned;
    if (plan == null) continue;
    if (slotTimePhaseForBlock(plan, nowMinutes) == SlotTimePhase.current) {
      currentIndex = i;
      break;
    }
  }
  if (currentIndex <= 0) return visible;
  final reordered = List<ComparisonSlot>.from(visible);
  final current = reordered.removeAt(currentIndex);
  reordered.insert(0, current);
  return reordered;
}

class CatchUpWindow {
  const CatchUpWindow({required this.start, required this.end});

  final TimeOfDay start;
  final TimeOfDay end;
}

TimeOfDay minutesToTimeOfDay(int totalMinutes) {
  final clamped = totalMinutes.clamp(0, 24 * 60 - 1);
  return TimeOfDay(hour: clamped ~/ 60, minute: clamped % 60);
}

/// 根据已结束的计划块与当前时间，建议补记起止（结束默认为现在）。
CatchUpWindow suggestCatchUpWindow({
  required List<ComparisonSlot> slots,
  required int nowMinutes,
}) {
  final plans = slots
      .map((s) => s.planned)
      .whereType<TimeBlock>()
      .where((p) => p.content.trim().isNotEmpty)
      .toList()
    ..sort((a, b) => parseTime(a.startTime).compareTo(parseTime(b.startTime)));

  for (var i = plans.length - 1; i >= 0; i--) {
    final end = parseTime(plans[i].endTime);
    if (end < nowMinutes) {
      final gap = nowMinutes - end;
      if (gap >= 5) {
        return CatchUpWindow(
          start: minutesToTimeOfDay(end),
          end: minutesToTimeOfDay(nowMinutes),
        );
      }
    }
  }

  final startMin = nowMinutes >= 30 ? nowMinutes - 30 : 0;
  return CatchUpWindow(
    start: minutesToTimeOfDay(startMin),
    end: minutesToTimeOfDay(nowMinutes),
  );
}