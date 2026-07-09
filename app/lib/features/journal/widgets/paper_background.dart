import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Claude-style cream canvas: soft vertical wash, no lined-paper texture.
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
          colors: [
            AppTheme.canvas,
            AppTheme.surfaceSoft,
          ],
        ),
      ),
      child: child,
    );
  }
}
