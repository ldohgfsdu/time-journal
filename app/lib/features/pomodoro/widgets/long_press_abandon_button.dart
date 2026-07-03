import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/copy.dart';
class LongPressAbandonButton extends StatefulWidget {
  const LongPressAbandonButton({
    super.key,
    required this.onAbandoned,
    this.holdDuration = const Duration(seconds: 2),
  });

  final Future<void> Function() onAbandoned;
  final Duration holdDuration;

  @override
  State<LongPressAbandonButton> createState() => _LongPressAbandonButtonState();
}

class _LongPressAbandonButtonState extends State<LongPressAbandonButton> {
  double _progress = 0;
  Timer? _timer;
  bool _holding = false;

  void _startHold() {
    if (_holding) return;
    setState(() {
      _holding = true;
      _progress = 0;
    });
    final started = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      final elapsed = DateTime.now().difference(started);
      final p = elapsed.inMilliseconds / widget.holdDuration.inMilliseconds;
      if (p >= 1) {
        t.cancel();
        _complete();
        return;
      }
      setState(() => _progress = p);
    });
  }

  void _cancelHold() {
    _timer?.cancel();
    if (!_holding) return;
    setState(() {
      _holding = false;
      _progress = 0;
    });
  }

  Future<void> _complete() async {
    setState(() {
      _holding = false;
      _progress = 0;
    });
    await widget.onAbandoned();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: SizedBox(
        width: 200,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progress.clamp(0.0, 1.0),
                  child: Container(color: Colors.white.withValues(alpha: 0.18)),
                ),
              ),
            ),
            Center(
              child: Text(
                _holding ? AppCopy.focusHolding : AppCopy.focusHoldToPause,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: _holding ? 0.95 : 0.72),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}