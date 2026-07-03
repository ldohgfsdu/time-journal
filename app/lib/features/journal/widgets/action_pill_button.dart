import 'package:flutter/material.dart';
import '../../../app/theme.dart';

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
      color: AppTheme.tomatoSoft,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 5 : 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 14 : 16, color: AppTheme.tomato),
              const SizedBox(width: 2),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.tomato,
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}