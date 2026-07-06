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
    // Softer, calmer ruled lines (low contrast, editorial)
    final paint = Paint()
      ..color = AppTheme.rule.withValues(alpha: 0.22)
      ..strokeWidth = 0.6;

    const gap = 32.0;
    for (var y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Very subtle left margin, no strong tomato
    final marginPaint = Paint()
      ..color = AppTheme.ink.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(24, 0), Offset(24, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}