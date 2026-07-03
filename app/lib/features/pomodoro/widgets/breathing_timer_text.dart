import 'package:flutter/material.dart';

/// 倒计时数字的「呼吸」微交互：每秒跳变时轻微缩放 0.3s，不打扰专注心流。
class BreathingTimerText extends StatefulWidget {
  const BreathingTimerText({
    super.key,
    required this.text,
    required this.style,
    this.enabled = true,
  });

  final String text;
  final TextStyle style;
  final bool enabled;

  @override
  State<BreathingTimerText> createState() => _BreathingTimerTextState();
}

class _BreathingTimerTextState extends State<BreathingTimerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.045),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.045, end: 1.0),
        weight: 55,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(BreathingTimerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && oldWidget.text != widget.text) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Text(widget.text, style: widget.style),
    );
  }
}