import 'package:flutter/material.dart';

/// 星空卡片：已点亮的星星静态展示，新点亮时带轻微缩放 + 发光动画。
class StarrySky extends StatefulWidget {
  const StarrySky({
    super.key,
    required this.litCount,
    this.total = 10,
  });

  final int litCount;
  final int total;

  @override
  State<StarrySky> createState() => _StarrySkyState();
}

class _StarrySkyState extends State<StarrySky> with SingleTickerProviderStateMixin {
  static const _litColor = Color(0xFFFFD76A);
  static const _animDuration = Duration(milliseconds: 520);

  late AnimationController _lightController;
  int _animateFromIndex = -1;

  @override
  void initState() {
    super.initState();
    _lightController = AnimationController(vsync: this, duration: _animDuration);
  }

  @override
  void didUpdateWidget(StarrySky oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.litCount > oldWidget.litCount) {
      _animateFromIndex = oldWidget.litCount;
      _lightController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _lightController.dispose();
    super.dispose();
  }

  double _starProgress(int index) {
    if (_animateFromIndex < 0 || index < _animateFromIndex) return 1;
    const stagger = 0.12;
    const span = 0.55;
    final start = (index - _animateFromIndex) * stagger;
    final raw = ((_lightController.value - start) / span).clamp(0.0, 1.0);
    return Curves.easeOut.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lightController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.total, (i) {
            final lit = i < widget.litCount;
            final progress = lit ? _starProgress(i) : 0.0;
            final animating = lit && _animateFromIndex >= 0 && i >= _animateFromIndex;

            final scale = lit
                ? (animating ? 0.55 + 0.45 * progress : 1.0)
                : 1.0;
            final glow = lit
                ? (animating ? progress : 1.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  lit ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: lit ? 22 : 18,
                  color: lit
                      ? _litColor.withValues(alpha: animating ? 0.35 + 0.65 * progress : 1)
                      : Colors.white.withValues(alpha: 0.22),
                  shadows: lit && glow > 0
                      ? [
                          Shadow(
                            color: _litColor.withValues(alpha: 0.8 * glow),
                            blurRadius: 6 + 10 * glow,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}