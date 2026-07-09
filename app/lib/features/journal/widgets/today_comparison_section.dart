import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/copy.dart';
import '../../../app/gentle_feedback.dart';
import '../../../app/shell_navigation.dart';
import '../../../app/theme.dart';
import '../../../core/utils/comparison_time.dart';
import '../../../data/local/database.dart';
import '../../../data/models/comparison_slot.dart';
import '../providers/journal_providers.dart';
import 'action_pill_button.dart';
import 'actual_edit_sheet.dart';
import 'schedule_sheet.dart';
import 'empty_add_slot.dart';
import 'section_card.dart';
import 'todo_pick_chips.dart';

class TodayComparisonSection extends ConsumerWidget {
  const TodayComparisonSection({
    super.key,
    required this.dateKey,
    required this.slots,
    required this.todos,
    required this.isToday,
  });

  final String dateKey;
  final List<ComparisonSlot> slots;
  final List<TodoItem> todos;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(journalRepositoryProvider);
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final visibleSlots = orderComparisonSlotsForToday(slots, nowMin);
    final showNoPlanNow = isToday &&
        visibleSlots.isNotEmpty &&
        !hasCurrentPlannedSlot(slots, nowMin);

    return SectionCard(
      title: AppCopy.journalCompareTitle,
      subtitle: AppCopy.journalCompareSubtitle,
      dense: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isToday)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showNoPlanNow
                          ? AppCopy.journalCompareNoPlanNowHint
                          : AppCopy.journalCompareCatchUpLead,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.tomato,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => _openCatchUp(context, ref, slots, nowMin),
                    child: Text(
                      showNoPlanNow
                          ? AppCopy.journalCompareCatchUpSegment
                          : AppCopy.journalCompareCatchUpAction,
                    ),
                  ),
                ],
              ),
            ),
          if (showNoPlanNow)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.tomatoSoft.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.tomato.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppCopy.journalCompareNoPlanNow,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} · ${AppCopy.journalCompareNoPlanNowHint}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (visibleSlots.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppCopy.journalCompareEmpty,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppCopy.journalCompareEmptyAction,
                    style: TextStyle(fontSize: 13, color: AppTheme.inkMuted),
                  ),
                ],
              ),
            )
          else
            for (final slot in visibleSlots)
              _SlotCard(
                slot: slot,
                isCurrent: isToday &&
                    slot.planned != null &&
                    slotTimePhaseForBlock(slot.planned!, nowMin) ==
                        SlotTimePhase.current,
                timePhase: isToday && slot.planned != null
                    ? slotTimePhaseForBlock(slot.planned!, nowMin)
                    : SlotTimePhase.past,
                isToday: isToday,
                todos: todos,
                scheduledTodoIds: visibleSlots
                    .where((s) => s.planned?.linkedTodoId != null)
                    .map((s) => s.planned!.linkedTodoId!)
                    .toSet(),
                onCompleteAsPlanned: () async {
                  await repo.completePlannedAsActual(dateKey, slot.planned!);
                  ref.invalidate(journalSnapshotProvider);
                  GentleFeedback.lightTap();
                },
                onEditActual: () => _editActual(context, ref, slot),
                onRevertActual: () async {
                  await repo.clearActualForPlan(dateKey, slot.planned!);
                  ref.invalidate(journalSnapshotProvider);
                  GentleFeedback.lightTap();
                },
                onPlanChanged: (updated) async {
                  await repo.updateBlock(updated);
                  ref.invalidate(journalSnapshotProvider);
                },
                onDeletePlan: () async {
                  await repo.removeBlock(slot.planned!.id);
                  ref.invalidate(journalSnapshotProvider);
                },
                onDeleteOrphan: () async {
                  if (slot.actual != null) {
                    await repo.removeBlock(slot.actual!.id);
                    ref.invalidate(journalSnapshotProvider);
                  }
                },
                onFocus: isToday && slot.planned != null
                    ? () {
                        final planned = slot.planned!;
                        GentleFeedback.lightTap();
                        navigateToFocusTab(
                          ref,
                          task: planned.content,
                          planId: planned.id,
                          todoId: planned.linkedTodoId,
                        );
                      }
                    : null,
              ),
          if (isToday)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: EmptyAddSlot(
                hint: AppCopy.journalCompareCatchUpSegment,
                onTap: () => _openCatchUp(context, ref, slots, nowMin),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openCatchUp(
    BuildContext context,
    WidgetRef ref,
    List<ComparisonSlot> slots,
    int nowMin,
  ) async {
    final window = suggestCatchUpWindow(slots: slots, nowMinutes: nowMin);
    final result = await showScheduleSheet(
      context,
      taskName: '',
      catchUp: true,
      catchUpStart: window.start,
      catchUpEnd: window.end,
    );
    if (result == null) return;
    final repo = ref.read(journalRepositoryProvider);
    await repo.createCatchUpActual(
      date: dateKey,
      startTime: result.startTime,
      endTime: result.endTime,
      content: result.content,
    );
    ref.invalidate(journalSnapshotProvider);
    GentleFeedback.lightTap();
  }

  Future<void> _editActual(
    BuildContext context,
    WidgetRef ref,
    ComparisonSlot slot,
  ) async {
    if (slot.planned == null && slot.actual != null) {
      final result = await showScheduleSheet(
        context,
        taskName: slot.actual!.content,
        catchUp: true,
      );
      if (result == null) return;
      final repo = ref.read(journalRepositoryProvider);
      await repo.updateBlock(slot.actual!.copyWith(
        content: result.content,
        startTime: result.startTime,
        endTime: result.endTime,
      ));
      ref.invalidate(journalSnapshotProvider);
      return;
    }

    final result = await showActualEditSheet(context, slot: slot);
    if (result == null) return;
    final repo = ref.read(journalRepositoryProvider);
    final actual = await repo.ensureActualSlot(dateKey, slot.planned!);
    await repo.updateBlock(actual.copyWith(
      content: result.content,
      startTime: result.startTime,
      endTime: result.endTime,
    ));
    ref.invalidate(journalSnapshotProvider);
    GentleFeedback.lightTap();
  }
}

class _SlotCard extends StatefulWidget {
  const _SlotCard({
    required this.slot,
    required this.isCurrent,
    required this.timePhase,
    required this.isToday,
    required this.todos,
    required this.scheduledTodoIds,
    required this.onCompleteAsPlanned,
    required this.onEditActual,
    required this.onRevertActual,
    required this.onPlanChanged,
    required this.onDeletePlan,
    required this.onDeleteOrphan,
    this.onFocus,
  });

  final ComparisonSlot slot;
  final bool isCurrent;
  final SlotTimePhase timePhase;
  final bool isToday;
  final List<TodoItem> todos;
  final Set<int> scheduledTodoIds;
  final VoidCallback onCompleteAsPlanned;
  final VoidCallback onEditActual;
  final VoidCallback onRevertActual;
  final ValueChanged<TimeBlock> onPlanChanged;
  final VoidCallback onDeletePlan;
  final VoidCallback onDeleteOrphan;
  final VoidCallback? onFocus;

  @override
  State<_SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<_SlotCard> {
  late final TextEditingController _planController;
  bool _editingPlan = false;
  bool _saving = false;

  VoidCallback _guard(VoidCallback action) => () {
        if (_saving) return;
        setState(() => _saving = true);
        action();
      };

  @override
  void initState() {
    super.initState();
    _planController = TextEditingController(
      text: widget.slot.planned?.content ?? '',
    );
  }

  @override
  void didUpdateWidget(_SlotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _saving = false;
    final content = widget.slot.planned?.content ?? '';
    if (content != _planController.text) {
      _planController.text = content;
    }
  }

  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.slot.planned;
    final status = widget.slot.status;
    final dimmed = widget.isToday && plan != null && !widget.isCurrent;
    final title = widget.slot.taskTitle;
    final actualText = status == SlotStatus.pending
        ? '未记录'
        : widget.slot.actualLabel;

    return AnimatedOpacity(
      opacity: dimmed ? 0.55 : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isCurrent
              ? AppTheme.tomatoSoft.withValues(alpha: 0.35)
              : AppTheme.paper.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isCurrent
                ? AppTheme.tomato.withValues(alpha: 0.35)
                : AppTheme.rule,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.isCurrent)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.tomato.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      AppCopy.journalCompareNow,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.tomato,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.slot.timeRange,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkMuted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if (plan != null) _StatusChip(status: status),
                _SlotMenu(
                  hasPlan: plan != null,
                  onEditPlan: plan != null
                      ? () => setState(() => _editingPlan = true)
                      : null,
                  onFocus: widget.onFocus,
                  onDelete: plan != null
                      ? widget.onDeletePlan
                      : widget.onDeleteOrphan,
                ),
              ],
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
            ],
            if ((plan != null || widget.slot.orphanActual) &&
                status != SlotStatus.match) ...[
              const SizedBox(height: 4),
              Text(
                '${AppCopy.journalCompareActualPrefix}$actualText',
                style: TextStyle(
                  fontSize: 14,
                  color: status == SlotStatus.pending
                      ? AppTheme.inkFaint
                      : AppTheme.ink,
                ),
              ),
            ],
            if (_editingPlan && plan != null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _planController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: AppCopy.journalBlockHint,
                  isDense: true,
                ),
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  widget.onPlanChanged(plan.copyWith(content: v.trim()));
                  setState(() => _editingPlan = false);
                },
              ),
              TodoPickChips(
                label: AppCopy.journalBlockPickTodo,
                todos: widget.todos,
                selectedId: plan.linkedTodoId,
                disabledIds: widget.scheduledTodoIds
                    .where((id) => id != plan.linkedTodoId)
                    .toSet(),
                onPick: (todo) {
                  _planController.text = todo.content;
                  widget.onPlanChanged(
                    plan.copyWith(
                      content: todo.content,
                      linkedTodoId: Value(todo.id),
                    ),
                  );
                },
              ),
            ],
            if (_actionButtons(status).isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _actionButtons(status),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _actionButtons(SlotStatus status) {
    if (widget.slot.orphanActual) {
      return [
        ActionPillButton(
          label: AppCopy.journalCompareEditActual,
          compact: true,
          onPressed: _guard(widget.onEditActual),
        ),
      ];
    }

    return switch (status) {
      SlotStatus.pending => widget.timePhase == SlotTimePhase.past
          ? [
              ActionPillButton(
                label: AppCopy.journalCompareCatchUpActual,
                compact: true,
                onPressed: _guard(widget.onEditActual),
              ),
              ActionPillButton(
                label: AppCopy.journalCompareAsPlanned,
                compact: true,
                onPressed: _guard(widget.onCompleteAsPlanned),
              ),
            ]
          : [
              ActionPillButton(
                label: AppCopy.journalCompareAsPlanned,
                compact: true,
                onPressed: _guard(widget.onCompleteAsPlanned),
              ),
              ActionPillButton(
                label: AppCopy.journalCompareChanged,
                compact: true,
                onPressed: _guard(widget.onEditActual),
              ),
            ],
      SlotStatus.match => [
          ActionPillButton(
            label: AppCopy.journalCompareEditActual,
            compact: true,
            onPressed: _guard(widget.onEditActual),
          ),
          ActionPillButton(
            label: AppCopy.journalCompareRevert,
            compact: true,
            onPressed: _guard(widget.onRevertActual),
          ),
        ],
      SlotStatus.changed => [
          ActionPillButton(
            label: AppCopy.journalCompareEditActual,
            compact: true,
            onPressed: _guard(widget.onEditActual),
          ),
          ActionPillButton(
            label: AppCopy.journalCompareMarkPlanned,
            compact: true,
            onPressed: _guard(widget.onCompleteAsPlanned),
          ),
        ],
      SlotStatus.unplanned => [],
    };
  }
}

class _SlotMenu extends StatelessWidget {
  const _SlotMenu({
    required this.hasPlan,
    required this.onEditPlan,
    required this.onDelete,
    this.onFocus,
  });

  final bool hasPlan;
  final VoidCallback? onEditPlan;
  final VoidCallback? onFocus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, size: 18, color: AppTheme.inkFaint),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      onSelected: (value) {
        switch (value) {
          case 'focus':
            onFocus?.call();
          case 'edit':
            onEditPlan?.call();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (ctx) => [
        if (hasPlan && onFocus != null)
          const PopupMenuItem(
            value: 'focus',
            child: Text(AppCopy.todoActionFocus),
          ),
        if (hasPlan && onEditPlan != null)
          const PopupMenuItem(
            value: 'edit',
            child: Text(AppCopy.journalCompareEditPlan),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Text(AppCopy.todoActionDelete),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SlotStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SlotStatus.match => (AppCopy.journalCompareStatusMatch, AppTheme.inkMuted),
      SlotStatus.pending => (AppCopy.journalCompareStatusPending, AppTheme.inkFaint),
      SlotStatus.changed => (AppCopy.journalCompareStatusChanged, AppTheme.inkMuted),
      SlotStatus.unplanned => (AppCopy.journalCompareStatusUnplanned, AppTheme.inkFaint),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.tagBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}