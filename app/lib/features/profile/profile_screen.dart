import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/copy.dart';
import '../../app/theme.dart';
import '../../data/local/database_provider.dart';
import '../journal/providers/journal_providers.dart';
import '../sleep/providers/sleep_provider.dart';
import '../weekly/weekly_screen.dart';
import '../weekly/providers/weekly_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.profileTitle)),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.calendar_view_week_outlined,
            title: AppCopy.weeklyTitle,
            subtitle: AppCopy.profileWeeklySubtitle,
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WeeklyScreen())),
          ),
          const _SettingsTile(
            icon: Icons.storage_outlined,
            title: AppCopy.profileDataTitle,
            subtitle: AppCopy.profileDataSubtitle,
          ),
          const _SettingsTile(
            icon: Icons.info_outline,
            title: AppCopy.profileAboutTitle,
            subtitle: AppCopy.profileAboutSubtitle,
          ),
          _SettingsTile(
            icon: Icons.settings_outlined,
            title: AppCopy.profileSettingsTitle,
            subtitle: AppCopy.profileSettingsSubtitle,
            onTap: () => _openSettings(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SettingsSheetRow(
                icon: Icons.palette_outlined,
                title: AppCopy.profileThemeTitle,
                subtitle: AppCopy.profileThemeCurrent,
              ),
              const Divider(height: 18),
              const _SettingsSheetRow(
                icon: Icons.storage_outlined,
                title: AppCopy.profileStorageTitle,
                subtitle: AppCopy.profileStorageLocal,
              ),
              const Divider(height: 18),
              _SettingsSheetRow(
                icon: Icons.delete_outline_rounded,
                title: AppCopy.profileClearDataTitle,
                subtitle: AppCopy.profileClearDataSubtitle,
                danger: true,
                onTap: () => _confirmClearData(sheetContext, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppCopy.profileClearDataConfirmTitle),
        content: const Text(AppCopy.profileClearDataConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppCopy.profileClearDataCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppCopy.profileClearDataConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(databaseProvider).clearAllData();
    ref.invalidate(journalSnapshotProvider);
    ref.invalidate(todayTodosProvider);
    ref.invalidate(sleepDataProvider);
    ref.invalidate(weeklySummaryProvider);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppCopy.profileClearDataDone)));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: AppTheme.inkMuted),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right_rounded, color: AppTheme.inkFaint)
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsSheetRow extends StatelessWidget {
  const _SettingsSheetRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppTheme.danger : AppTheme.inkMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: danger ? AppTheme.danger : AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
