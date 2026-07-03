import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';

class ScheduleSheetResult {
  const ScheduleSheetResult({
    required this.startTime,
    required this.endTime,
    required this.content,
  });

  final String startTime;
  final String endTime;
  final String content;
}

Future<ScheduleSheetResult?> showScheduleSheet(
  BuildContext context, {
  required String taskName,
  bool catchUp = false,
}) {
  return showModalBottomSheet<ScheduleSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _ScheduleSheetBody(
      taskName: taskName,
      catchUp: catchUp,
    ),
  );
}

class _ScheduleSheetBody extends StatefulWidget {
  const _ScheduleSheetBody({
    required this.taskName,
    required this.catchUp,
  });

  final String taskName;
  final bool catchUp;

  @override
  State<_ScheduleSheetBody> createState() => _ScheduleSheetBodyState();
}

class _ScheduleSheetBodyState extends State<_ScheduleSheetBody> {
  late TimeOfDay _start;
  late TimeOfDay _end;
  late final TextEditingController _contentController;
  int? _durationMinutes;

  static const _maxMinutesWithoutConfirm = 4 * 60;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _start = now;
    _end = _addMinutes(now, 60);
    _durationMinutes = 60;
    _contentController = TextEditingController(text: widget.taskName.trim());
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final total = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  int _durationBetween(TimeOfDay start, TimeOfDay end) {
    var startMin = start.hour * 60 + start.minute;
    var endMin = end.hour * 60 + end.minute;
    if (endMin <= startMin) endMin += 24 * 60;
    return endMin - startMin;
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatDurationLabel(int minutes) => AppCopy.fmtDuration(minutes);

  void _setStartNow() {
    setState(() {
      _start = TimeOfDay.now();
      final minutes = _durationMinutes ?? 60;
      _durationMinutes = minutes;
      _end = _addMinutes(_start, minutes);
    });
  }

  void _setDuration(int minutes) {
    setState(() {
      _durationMinutes = minutes;
      _end = _addMinutes(_start, minutes);
    });
  }

  ThemeData _timePickerTheme() => AppTheme.light().copyWith(
        colorScheme: AppTheme.light().colorScheme.copyWith(
              secondary: AppTheme.tomato,
            ),
        dialogTheme: const DialogThemeData(
          barrierColor: Colors.black54,
          backgroundColor: AppTheme.paper,
        ),
      );

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start,
      builder: (context, child) => Theme(
        data: _timePickerTheme(),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _start = picked;
      if (_durationMinutes != null) {
        _end = _addMinutes(_start, _durationMinutes!);
      }
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _end,
      builder: (context, child) => Theme(
        data: _timePickerTheme(),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _end = picked;
      _durationMinutes = null;
    });
  }

  Future<bool> _confirmLongDurationIfNeeded() async {
    final minutes = _durationBetween(_start, _end);
    if (minutes <= _maxMinutesWithoutConfirm) return true;
    final label = _formatDurationLabel(minutes);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认时段'),
        content: Text(AppCopy.scheduleLongDurationConfirm(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('返回修改'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定安排'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _confirm() async {
    final content = widget.catchUp
        ? _contentController.text.trim()
        : widget.taskName.trim();
    if (content.isEmpty) return;
    if (!await _confirmLongDurationIfNeeded()) return;
    if (!mounted) return;
    Navigator.pop(
      context,
      ScheduleSheetResult(
        startTime: _format(_start),
        endTime: _format(_end),
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.catchUp
        ? AppCopy.journalCompareCatchUpLead
        : AppCopy.scheduleTitle(widget.taskName.trim().isEmpty
            ? AppCopy.journalTodoHint
            : widget.taskName.trim());

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (widget.catchUp) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: AppCopy.journalBlockHint,
                labelText: AppCopy.scheduleCatchUpContent,
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            AppCopy.scheduleStartLabel,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ChoiceChip(
                label: '${AppCopy.scheduleStartNow} ${_format(_start)}',
                selected: true,
                onTap: _setStartNow,
              ),
              const SizedBox(width: 8),
              _ChoiceChip(
                label: AppCopy.scheduleChangeTime,
                selected: false,
                onTap: _pickStart,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            AppCopy.scheduleDurationLabel,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChoiceChip(
                label: AppCopy.scheduleDuration15,
                selected: _durationMinutes == 15,
                onTap: () => _setDuration(15),
              ),
              _ChoiceChip(
                label: AppCopy.scheduleDuration30,
                selected: _durationMinutes == 30,
                onTap: () => _setDuration(30),
              ),
              _ChoiceChip(
                label: AppCopy.scheduleDuration60,
                selected: _durationMinutes == 60,
                onTap: () => _setDuration(60),
              ),
              _ChoiceChip(
                label: AppCopy.scheduleDuration120,
                selected: _durationMinutes == 120,
                onTap: () => _setDuration(120),
              ),
              _ChoiceChip(
                label: AppCopy.scheduleCustomDuration,
                selected: _durationMinutes == null,
                onTap: _pickEnd,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppCopy.schedulePreview(_format(_start), _format(_end)),
            style: const TextStyle(fontSize: 13, color: AppTheme.inkFaint),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              final canConfirm = widget.catchUp
                  ? _contentController.text.trim().isNotEmpty
                  : widget.taskName.trim().isNotEmpty;
              if (canConfirm) _confirm();
            },
            child: Text(widget.catchUp
                ? AppCopy.scheduleConfirmCatchUp
                : AppCopy.scheduleConfirm),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.tomatoSoft.withValues(alpha: 0.8)
          : AppTheme.tagBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.tomato.withValues(alpha: 0.35) : AppTheme.rule,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppTheme.tomato : AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}