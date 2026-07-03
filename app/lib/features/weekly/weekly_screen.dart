import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/copy.dart';
import '../../app/theme.dart';
import '../../data/repositories/weekly_repository.dart';
import '../journal/widgets/paper_background.dart';
import '../journal/widgets/section_card.dart';
import 'providers/weekly_provider.dart';
import 'widgets/week_activity_strip.dart';
import 'widgets/weekly_delta.dart';

class WeeklyScreen extends ConsumerStatefulWidget {
  const WeeklyScreen({super.key});

  @override
  ConsumerState<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends ConsumerState<WeeklyScreen> {
  final _reflectionController = TextEditingController();
  Timer? _reflectionDebounce;
  String? _loadedWeekKey;

  @override
  void dispose() {
    _reflectionDebounce?.cancel();
    _reflectionController.dispose();
    super.dispose();
  }

  void _syncReflection(String weekMondayKey, String note) {
    if (_loadedWeekKey == weekMondayKey) return;
    _loadedWeekKey = weekMondayKey;
    _reflectionController.text = note;
  }

  void _saveReflectionDebounced(DateTime monday, String note) {
    _reflectionDebounce?.cancel();
    _reflectionDebounce = Timer(const Duration(milliseconds: 500), () async {
      await ref.read(weeklyRepositoryProvider).saveReflection(monday, note);
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(weeklySummaryProvider);
    final monday = ref.watch(selectedWeekMondayProvider);

    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: () {
                ref.read(selectedWeekMondayProvider.notifier).state =
                    monday.subtract(const Duration(days: 7));
              },
            ),
            const Text(AppCopy.weeklyTitle),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: _canGoForward(monday)
                  ? () {
                      ref.read(selectedWeekMondayProvider.notifier).state =
                          monday.add(const Duration(days: 7));
                    }
                  : null,
            ),
          ],
        ),
      ),
      body: PaperBackground(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.tomato)),
          error: (e, _) => Center(child: Text(AppCopy.loadErrorDetail(e))),
          data: (summary) {
            final weekKey = DateFormat('yyyy-MM-dd').format(summary.week.monday);
            _syncReflection(weekKey, summary.reflectionNote);

            return ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    AppCopy.weeklyHeader(
                      summary.week.weekNumber,
                      summary.week.label,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppCopy.weeklySoulLine1,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.inkMuted.withValues(alpha: 0.9),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppCopy.weeklySoulLine2,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.inkMuted.withValues(alpha: 0.9),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.tomatoSoft.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.rule),
                  ),
                  child: Text(
                    AppCopy.weeklyAttendance(summary.attendanceDays),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              SectionCard(
                title: AppCopy.weeklyTrackTitle,
                child: Column(
                  children: [
                    WeekHeatmapHeader(days: summary.days),
                    WeekActivityStrip(
                      label: AppCopy.weeklyTrackJournal,
                      days: summary.days,
                      metric: WeekStripMetric.journal,
                    ),
                    const SizedBox(height: 8),
                    WeekActivityStrip(
                      label: AppCopy.weeklyTrackFocus,
                      days: summary.days,
                      metric: WeekStripMetric.focus,
                    ),
                    const SizedBox(height: 8),
                    WeekActivityStrip(
                      label: AppCopy.weeklyTrackSleep,
                      days: summary.days,
                      metric: WeekStripMetric.sleep,
                    ),
                  ],
                ),
              ),
                SectionCard(
                  title: AppCopy.weeklyJournalTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bullet(AppCopy.weeklyJournalDaysWarm(summary.journalDays)),
                      const SizedBox(height: 6),
                      _Bullet(
                        AppCopy.weeklyPlanCompare(
                          summary.plannedStudyMinutes,
                          summary.actualStudyMinutes,
                        ),
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: AppCopy.weeklyFocusTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bullet(
                        AppCopy.weeklyFocusSummary(
                          summary.focusSessions,
                          summary.focusMinutes,
                        ),
                      ),
                      if (summary.topFocusPresetMinutes != null) ...[
                        const SizedBox(height: 6),
                        _Bullet(
                          AppCopy.weeklyFocusPreset(summary.topFocusPresetMinutes!),
                        ),
                      ],
                      const SizedBox(height: 8),
                      WeeklyDelta(
                        delta: summary.focusMinutesDelta,
                        hasActivity: summary.focusMinutes > 0,
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: AppCopy.weeklySleepTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary.avgBedtimeLabel != null)
                        _Bullet(
                            AppCopy.weeklySleepBedtime(summary.avgBedtimeLabel!)),
                      const SizedBox(height: 6),
                      _Bullet(AppCopy.weeklySleepEarly(summary.earlySleepDays)),
                      if (summary.earlySleepDays > 0) ...[
                        const SizedBox(height: 6),
                        _Bullet(AppCopy.weeklySleepStars(summary.starsLit)),
                      ],
                      const SizedBox(height: 8),
                      WeeklyDelta(
                        delta: summary.earlySleepDelta,
                        hasActivity: summary.earlySleepDays > 0,
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: AppCopy.weeklyReflectionTitle,
                  subtitle: AppCopy.weeklyReflectionSubtitle,
                  child: TextField(
                    controller: _reflectionController,
                    minLines: 3,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: AppCopy.weeklyReflectionHint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.rule),
                      ),
                    ),
                    onChanged: (v) =>
                        _saveReflectionDebounced(summary.week.monday, v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Text(
                    AppCopy.weeklyMirrorQuote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.inkMuted.withValues(alpha: 0.85),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _canGoForward(DateTime monday) {
    final thisMonday = WeeklyRepository.mondayOf(DateTime.now());
    return monday.isBefore(thisMonday);
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('· ', style: TextStyle(color: AppTheme.inkFaint, fontSize: 15)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppTheme.ink, height: 1.45),
          ),
        ),
      ],
    );
  }
}