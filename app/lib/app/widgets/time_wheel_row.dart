import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Rounds [minute] to nearest step (0–59).
int roundMinuteToStep(int minute, {int step = 5}) {
  if (step <= 1) return minute.clamp(0, 59);
  final rounded = ((minute + step ~/ 2) ~/ step) * step;
  return rounded >= 60 ? 0 : rounded;
}

TimeOfDay? tryParseTimeOfDay(String raw) {
  final text = raw.trim().replaceAll('：', ':');
  final match = RegExp(r'^(\d{1,2}):(\d{1,2})$').firstMatch(text);
  if (match == null) return null;
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String formatTimeOfDay(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// Hand-journal style hour : minute wheels (24h, infinite loop) + keyboard entry.
class TimeWheelRow extends StatefulWidget {
  const TimeWheelRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.minuteStep = 1,
    this.height = 148,
    this.showKeyboardField = true,
  });

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  final int minuteStep;
  final double height;
  final bool showKeyboardField;

  @override
  State<TimeWheelRow> createState() => _TimeWheelRowState();
}

class _TimeWheelRowState extends State<TimeWheelRow> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late TextEditingController _textController;
  late FocusNode _textFocus;
  late List<int> _minuteSlots;
  var _syncingControllers = false;

  @override
  void initState() {
    super.initState();
    _minuteSlots = _buildMinuteSlots(widget.minuteStep);
    final rounded = _roundedValue(widget.value);
    _hourController = FixedExtentScrollController(initialItem: rounded.hour);
    _minuteController = FixedExtentScrollController(
      initialItem: _minuteIndex(rounded.minute),
    );
    _textController = TextEditingController(text: formatTimeOfDay(rounded));
    _textFocus = FocusNode();
    _textFocus.addListener(_onTextFocusChange);
  }

  @override
  void didUpdateWidget(covariant TimeWheelRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minuteStep != widget.minuteStep) {
      _minuteSlots = _buildMinuteSlots(widget.minuteStep);
    }
    final rounded = _roundedValue(widget.value);
    final current = _currentValue();
    if (current.hour != rounded.hour || current.minute != rounded.minute) {
      _jumpTo(rounded);
    }
    if (!_textFocus.hasFocus) {
      final label = formatTimeOfDay(rounded);
      if (_textController.text != label) {
        _textController.value = TextEditingValue(
          text: label,
          selection: TextSelection.collapsed(offset: label.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _textFocus.removeListener(_onTextFocusChange);
    _hourController.dispose();
    _minuteController.dispose();
    _textController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  List<int> _buildMinuteSlots(int step) {
    final s = step <= 1 ? 1 : step;
    return List<int>.generate(60 ~/ s, (i) => i * s);
  }

  TimeOfDay _roundedValue(TimeOfDay value) {
    return TimeOfDay(
      hour: value.hour.clamp(0, 23),
      minute: roundMinuteToStep(value.minute, step: widget.minuteStep),
    );
  }

  int _minuteIndex(int minute) {
    final idx = _minuteSlots.indexOf(minute);
    return idx < 0 ? 0 : idx;
  }

  TimeOfDay _currentValue() {
    final hour = _hourController.hasClients
        ? _hourController.selectedItem % 24
        : widget.value.hour;
    final minuteIndex = _minuteController.hasClients
        ? _minuteController.selectedItem % _minuteSlots.length
        : _minuteIndex(widget.value.minute);
    return TimeOfDay(
      hour: hour < 0 ? (hour % 24 + 24) % 24 : hour,
      minute: _minuteSlots[minuteIndex < 0
          ? (minuteIndex % _minuteSlots.length + _minuteSlots.length) %
              _minuteSlots.length
          : minuteIndex],
    );
  }

  void _jumpTo(TimeOfDay time) {
    _syncingControllers = true;
    if (_hourController.hasClients) {
      // Keep nearby scroll position when looping.
      final current = _hourController.selectedItem;
      final base = current - (current % 24);
      _hourController.jumpToItem(base + time.hour);
    }
    if (_minuteController.hasClients) {
      final current = _minuteController.selectedItem;
      final len = _minuteSlots.length;
      final base = current - (current % len);
      _minuteController.jumpToItem(base + _minuteIndex(time.minute));
    }
    _syncingControllers = false;
  }

  void _emit(TimeOfDay time) {
    final rounded = _roundedValue(time);
    if (!_textFocus.hasFocus) {
      final label = formatTimeOfDay(rounded);
      if (_textController.text != label) {
        _textController.value = TextEditingValue(
          text: label,
          selection: TextSelection.collapsed(offset: label.length),
        );
      }
    }
    widget.onChanged(rounded);
  }

  void _onHourSelected(int index) {
    if (_syncingControllers) return;
    final hour = ((index % 24) + 24) % 24;
    final minute = _currentValue().minute;
    _emit(TimeOfDay(hour: hour, minute: minute));
  }

  void _onMinuteSelected(int index) {
    if (_syncingControllers) return;
    final len = _minuteSlots.length;
    final minuteIndex = ((index % len) + len) % len;
    final hour = _currentValue().hour;
    _emit(TimeOfDay(hour: hour, minute: _minuteSlots[minuteIndex]));
  }

  void _onTextFocusChange() {
    if (_textFocus.hasFocus) return;
    _applyTextInput();
  }

  void _applyTextInput() {
    final parsed = tryParseTimeOfDay(_textController.text);
    if (parsed == null) {
      final label = formatTimeOfDay(_roundedValue(widget.value));
      _textController.value = TextEditingValue(
        text: label,
        selection: TextSelection.collapsed(offset: label.length),
      );
      return;
    }
    final rounded = _roundedValue(parsed);
    _jumpTo(rounded);
    _emit(rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppTheme.surfaceSoft,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: _hourController,
                  itemExtent: 36,
                  magnification: 1.08,
                  squeeze: 1.05,
                  useMagnifier: true,
                  looping: true,
                  onSelectedItemChanged: _onHourSelected,
                  children: List.generate(
                    24,
                    (h) => Center(
                      child: Text(
                        h.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.inkMuted,
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: _minuteController,
                  itemExtent: 36,
                  magnification: 1.08,
                  squeeze: 1.05,
                  useMagnifier: true,
                  looping: true,
                  onSelectedItemChanged: _onMinuteSelected,
                  children: _minuteSlots
                      .map(
                        (m) => Center(
                          child: Text(
                            m.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        if (widget.showKeyboardField) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            focusNode: _textFocus,
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9:：]')),
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: InputDecoration(
              isDense: true,
              labelText: '键盘输入时间',
              hintText: '例如 14:30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onSubmitted: (_) => _applyTextInput(),
            onEditingComplete: _applyTextInput,
          ),
        ],
      ],
    );
  }
}
