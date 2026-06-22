import 'package:flutter/material.dart';
import '../../../data/local/database.dart';

class TimeBlockEditor extends StatelessWidget {
  const TimeBlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
  });

  final TimeBlock block;
  final ValueChanged<TimeBlock> onChanged;
  final VoidCallback onDelete;

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final parts = (isStart ? block.startTime : block.endTime).split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final value = ':';
    onChanged(block.copyWith(
      startTime: isStart ? value : block.startTime,
      endTime: isStart ? block.endTime : value,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              TextButton(
                onPressed: () => _pickTime(context, true),
                child: Text(block.startTime),
              ),
              const Text('至'),
              TextButton(
                onPressed: () => _pickTime(context, false),
                child: Text(block.endTime),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: block.content,
              minLines: 1,
              maxLines: null,
              decoration: const InputDecoration(hintText: '这一时段做什么...'),
              onChanged: (v) => onChanged(block.copyWith(content: v)),
            ),
          ),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }
}
