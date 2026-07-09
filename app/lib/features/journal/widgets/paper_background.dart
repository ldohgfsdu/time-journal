import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Claude cream canvas — flat warm floor, no notebook lines.
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.canvas,
      child: child,
    );
  }
}
