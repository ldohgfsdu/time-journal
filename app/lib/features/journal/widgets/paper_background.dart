import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.paper, AppTheme.paperDeep],
        ),
      ),
      child: CustomPaint(
        painter: _RuledPaperPainter(),
        child: child,
      ),
    );
  }
}

class _RuledPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.rule.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;

    const gap = 28.0;
    for (var y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final marginPaint = Paint()
      ..color = AppTheme.tomato.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(20, 0), Offset(20, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}