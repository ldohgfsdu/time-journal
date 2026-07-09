import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';

/// Compact secondary control — hairline cream chip, not heavy coral pill.
class ActionPillButton extends StatelessWidget {
  const ActionPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.canvas,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 15 : 16, color: AppTheme.ink),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppTheme.ink,
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
