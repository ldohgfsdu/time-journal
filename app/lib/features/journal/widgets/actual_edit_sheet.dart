import 'package:flutter/material.dart';
import '../../../app/copy.dart';
import '../../../app/theme.dart';
import '../../../data/models/comparison_slot.dart';

class ActualEditResult {
  const ActualEditResult({
    required this.content,
    required this.startTime,
    required this.endTime,
  });

  final String content;
  final String startTime;
  final String endTime;
}

Future<ActualEditResult?> showActualEditSheet(
  BuildContext context, {
  required ComparisonSlot slot,
}) {
  return showModalBottomSheet<ActualEditResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _ActualEditBody(slot: slot),
  );
}

class _ActualEditBody extends StatefulWidget {
  const _ActualEditBody({required this.slot});

  final ComparisonSlot slot;

  @override
  State<_ActualEditBody> createState() => _ActualEditBodyState();
}

class _ActualEditBodyState extends State<_ActualEditBody> {
  late final TextEditingController _contentController;
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    final plan = widget.slot.planned!;
    final actual = widget.slot.actual;
    _contentController = TextEditingController(
      text: (actual?.content.trim().isNotEmpty ?? false)
          ? actual!.content.trim()
          : plan.content.trim(),
    );
    _start = _parseTime(actual?.startTime ?? plan.startTime);
    _end = _parseTime(actual?.endTime ?? plan.endTime);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
      helpText: start
          ? AppCopy.scheduleEditActualStart
          : AppCopy.scheduleEditActualEnd,
      builder: (context, child) => Theme(
        data: AppTheme.light().copyWith(
          colorScheme: AppTheme.light().colorScheme.copyWith(
                secondary: AppTheme.tomato,
              ),
          dialogTheme: const DialogThemeData(
            barrierColor: Colors.black54,
            backgroundColor: AppTheme.paper,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _save() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    Navigator.pop(
      context,
      ActualEditResult(
        content: content,
        startTime: _format(_start),
        endTime: _format(_end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.slot.planned!;
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
          const Text(
            AppCopy.journalCompareEditActual,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            AppCopy.journalCompareEditActualHint(
              plan.content.trim(),
              plan.startTime,
              plan.endTime,
            ),
            style: const TextStyle(fontSize: 13, color: AppTheme.inkMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            autofocus: true,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: AppCopy.journalCompareActualLabel,
              hintText: AppCopy.journalBlockHint,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(start: true),
                  child: Text('${AppCopy.scheduleStartLabel} ${_format(_start)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(start: false),
                  child: Text('${AppCopy.scheduleEndLabel} ${_format(_end)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: const Text(AppCopy.scheduleSave),
          ),
        ],
      ),
    );
  }
}