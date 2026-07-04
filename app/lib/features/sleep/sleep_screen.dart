import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/copy.dart';
import '../../app/gentle_feedback.dart';
import '../../app/picker_helper.dart';
import '../../app/theme.dart';
import '../../data/local/database_provider.dart';
import '../journal/widgets/section_card.dart';
import 'providers/sleep_noise_provider.dart';
import 'providers/sleep_provider.dart';
import 'widgets/sleep_week_dots.dart';

class SleepScreen extends ConsumerStatefulWidget {
  const SleepScreen({super.key});

  @override
  ConsumerState<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends ConsumerState<SleepScreen> {
  Future<void> _pickTime({
    required bool bedtime,
    required String current,
  }) async {
    final parts = current.split(':');
    final picked = await safeShowTimePicker(
      context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      helpText: bedtime ? AppCopy.sleepPickBedtime : AppCopy.sleepPickWake,
    );
    if (!mounted || picked == null) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final data = await ref.read(sleepDataProvider.future);
    await updateSleepSchedule(
      ref,
      bedtime: bedtime ? value : data.record.targetBedtime,
      wakeTime: bedtime ? data.record.targetWakeTime : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sleepAsync = ref.watch(sleepDataProvider);
    final noise = ref.watch(sleepNoiseProvider);
    final noiseController = ref.read(sleepNoiseProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.sleepTitle)),
      body: sleepAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.tomato)),
        error: (e, _) => Center(child: Text(AppCopy.loadErrorDetail(e))),
        data: (data) {
          final weekDots = (data.streakDays % 7).clamp(0, 7);
          final bedtimeText = data.record.actualBedtime == null
              ? AppCopy.sleepCheckInPending
              : DateFormat('HH:mm').format(data.record.actualBedtime!);
          final checkedIn = data.record.actualBedtime != null;
          final wakeText = data.record.actualWakeTime == null
              ? AppCopy.sleepWakePending
              : AppCopy.sleepWakeRecorded(
                  DateFormat('HH:mm').format(data.record.actualWakeTime!),
                );
          final wokeUp = data.record.actualWakeTime != null;
          final durationText = formatSleepDuration(
            actualBedtime: data.record.actualBedtime,
            actualWakeTime: data.record.actualWakeTime,
          );

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  color: AppTheme.sleepMist,
                  border: Border.all(color: AppTheme.rule),
                ),
                child: Column(
                  children: [
                    SleepWeekDots(litCount: weekDots),
                    const SizedBox(height: 12),
                    Text(
                      AppCopy.sleepHeroLine(data.streakDays),
                      style: const TextStyle(
                        color: AppTheme.sleepBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppCopy.sleepStreakNights(data.streakDays),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: AppCopy.sleepScheduleTitle,
                child: Column(
                  children: [
                    Text(
                      AppCopy.sleepTonightSchedule(
                        data.record.targetBedtime,
                        data.record.targetWakeTime,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.sleepBlue,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ScheduleChip(
                            label: AppCopy.sleepBedtimeLabel,
                            value: data.record.targetBedtime,
                            onTap: () => _pickTime(
                              bedtime: true,
                              current: data.record.targetBedtime,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ScheduleChip(
                            label: AppCopy.sleepWakeLabel,
                            value: data.record.targetWakeTime,
                            onTap: () => _pickTime(
                              bedtime: false,
                              current: data.record.targetWakeTime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.sleepBlue,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    final message = await checkInBedtime(ref);
                    if (!context.mounted) return;
                    GentleFeedback.sleepCheckIn(context, message);
                  },
                  child: const Text(AppCopy.sleepCheckInButton),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.sleepBlue,
                    side: const BorderSide(color: AppTheme.sleepBlue),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    await checkInWakeTime(db);
                    ref.invalidate(sleepDataProvider);
                    if (!context.mounted) return;
                    GentleFeedback.lightTap();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppCopy.sleepWakeFeedback),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(AppCopy.sleepWakeButton),
                ),
              ),
              SectionCard(
                title: AppCopy.sleepNoiseTitle,
                subtitle: AppCopy.sleepNoiseSubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sleepNoiseOptions.map((opt) {
                        final selected = noise.selected == opt.id;
                        final playing = selected && noise.playing;
                        return _NoiseChip(
                          label: opt.label,
                          selected: selected,
                          playing: playing,
                          loading: selected && noise.loading,
                          onTap: () async {
                            GentleFeedback.lightTap();
                            await noiseController.select(opt.id);
                            final error = ref.read(sleepNoiseProvider).error;
                            if (!context.mounted || error == null) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    if (noise.error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        noise.error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.danger,
                        ),
                      ),
                    ],
                    if (noise.selected != null && noise.playing) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${sleepNoiseOptions.firstWhere((o) => o.id == noise.selected).label}  ${AppCopy.sleepNoisePlaying}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.sleepBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              GentleFeedback.lightTap();
                              await noiseController.stop();
                            },
                            child: const Text(AppCopy.sleepNoiseStop),
                          ),
                        ],
                      ),
                      Slider(
                        value: noise.volume,
                        activeColor: AppTheme.sleepBlue,
                        onChanged: (value) {
                          unawaited(noiseController.setVolume(value));
                        },
                      ),
                    ],
                  ],
                ),
              ),
              SectionCard(
                title: AppCopy.sleepRecordTitle,
                child: Column(
                  children: [
                    _RecordRow(
                      label: AppCopy.sleepCheckInLabel,
                      value: bedtimeText,
                      valueColor: checkedIn
                          ? AppTheme.sleepBlue
                          : AppTheme.inkFaint,
                      emphasized: checkedIn,
                    ),
                    const SizedBox(height: 10),
                    _RecordRow(
                      label: AppCopy.sleepWakeLabel,
                      value: wakeText,
                      valueColor: wokeUp ? AppTheme.sleepBlue : AppTheme.inkFaint,
                      emphasized: wokeUp,
                    ),
                    if (durationText != null) ...[
                      const SizedBox(height: 10),
                      _RecordRow(
                        label: AppCopy.sleepDurationLabel,
                        value: durationText,
                        valueColor: AppTheme.sleepBlue,
                        emphasized: true,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _RecordRow(
                      label: AppCopy.sleepScoreLabel,
                      value: checkedIn
                          ? '${data.record.sleepScore} 分'
                          : AppCopy.sleepScorePending,
                      valueColor: _sleepScoreColor(
                        checkedIn: checkedIn,
                        score: data.record.sleepScore,
                      ),
                      emphasized: checkedIn && data.record.sleepScore > 0,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Color _sleepScoreColor({required bool checkedIn, required int score}) {
  if (!checkedIn) return AppTheme.inkFaint;
  if (score >= 5) return AppTheme.sleepBlue;
  return AppTheme.inkMuted;
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.paperDeep.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.rule),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.inkMuted),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.sleepBlue,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.subtitle),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: emphasized ? 16 : 15,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoiseChip extends StatelessWidget {
  const _NoiseChip({
    required this.label,
    required this.selected,
    required this.playing,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool playing;
  final bool loading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppTheme.sleepBlue.withValues(alpha: 0.12)
          : AppTheme.paperDeep.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => unawaited(onTap()),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppTheme.sleepBlue.withValues(alpha: 0.5)
                  : AppTheme.rule,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.tomato),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                playing ? '$label · ${AppCopy.sleepNoisePlaying}' : label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppTheme.sleepBlue : AppTheme.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
