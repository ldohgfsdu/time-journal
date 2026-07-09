import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';

/// Claude feature-card: surface-card cream, hairline, generous padding, calm title.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.subtitle,
    this.dense = false,
    this.editorialTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool dense;
  /// Use Cormorant serif for title (editorial band).
  final bool editorialTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: dense ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              dense ? 14 : 18,
              16,
              dense ? 10 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: editorialTitle
                            ? AppTheme.display(
                                size: 22,
                                weight: FontWeight.w500,
                                height: 1.2,
                                letterSpacing: -0.3,
                              )
                            : GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.ink,
                                height: 1.3,
                                letterSpacing: -0.1,
                              ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.muted,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, dense ? 14 : 18),
            child: child,
          ),
        ],
      ),
    );
  }
}
