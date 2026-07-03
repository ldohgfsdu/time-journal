/// 全 App 文案 —— 温和陪伴的记录助手语气
class AppCopy {
  AppCopy._();

  static const slogan = '帮你把一天想清楚、专注做完、安稳睡下的手账伙伴';

  // ── 通用 ──
  static const loadError = '暂时没加载出来，下拉刷新试试';
  static String loadErrorDetail(Object e) => '$loadError（$e）';

  // ── 手账 ──
  static const journalTitle = '时间管理手账';
  static const journalTodoTitle = '待办事项';
  static const journalTodoSubtitle = '先把想到的写下来，不必一次想全';
  static const journalTodoEmpty = '新的一天，有什么想完成的？';
  static const journalTodoHint = '写一件小事也可以';
  static const journalTodoAdd = '添加';
  static const journalTodoArrange = '安排';
  static const journalTodoScheduled = '已排期';
  static const journalTodoSwipeDelete = '删除';
  static const journalTodoShowMore = '查看更多';
  static String journalTodoShowMoreCount(int n) => '查看更多 $n 条';

  static const journalCompareTitle = '今日对照';
  static const journalCompareSubtitle = '看看计划和现实差在哪里';
  static const journalCompareEmpty = '还没有安排时间';
  static const journalCompareEmptyAction = '从待办里点「安排」开始';
  static const journalCompareCatchUpAction = '补上';
  static const journalCompareCatchUpLead = '漏记了一段？';
  static const journalComparePlanLabel = '计划';
  static const journalCompareActualLabel = '实际';
  static const journalCompareStatusMatch = '一致';
  static const journalCompareStatusPending = '待补';
  static const journalCompareStatusChanged = '有变';
  static const journalCompareStatusUnplanned = '未计划';
  static const journalCompareAsPlanned = '按计划完成';
  static const journalCompareCatchUpActual = '补记实际';
  static const journalCompareChanged = '实际有变';
  static const journalCompareActualPrefix = '实际：';
  static const journalCompareEditActual = '编辑实际';
  static const journalCompareRevert = '撤销';
  static const journalCompareMarkPlanned = '标为按计划';
  static const journalCompareEditPlan = '改计划';
  static String journalCompareEditActualHint(
    String task,
    String start,
    String end,
  ) => '原计划：$task · $start - $end';
  static const journalCompareNow = '现在';
  static const journalCompareNoPlanNow = '当前没有计划';
  static const journalBlockPickTodo = '从待办带入';
  static const journalTodoChipScheduled = '已在其他时段安排';
  static const scheduleStartLabel = '开始时间';
  static const scheduleEndLabel = '结束时间';
  static const scheduleStartNow = '现在';
  static const scheduleChangeTime = '改时间';
  static const scheduleCustomDuration = '自定义时长';
  static const scheduleDurationLabel = '持续时间';
  static const scheduleDuration15 = '15 分钟';
  static const scheduleDuration30 = '30 分钟';
  static const scheduleDuration60 = '1 小时';
  static const scheduleDuration120 = '2 小时';
  static String scheduleLongDurationConfirm(String duration) =>
      '这个时段有点长，确定安排 $duration 吗？';

  static const scheduleConfirm = '确认安排';
  static const scheduleConfirmCatchUp = '确认补记';
  static const scheduleSave = '保存';
  static const scheduleCatchUpContent = '这段时间在做什么';
  static String scheduleTitle(String task) => '安排：$task';
  static String schedulePreview(String start, String end) => '预计：$start - $end';
  static const journalBlockHint = '这一时段，打算做什么…';

  static const journalStatsTitle = '今日统计';
  static String journalStatsPlanned(int segments, String duration) =>
      '计划 $segments 段 · $duration';
  static String journalStatsActual(int segments, String duration) =>
      '实际 $segments 段 · $duration';
  static String journalStatsFocus(String duration) => '专注 $duration';

  static const journalNotesTitle = '今天一句话';
  static const journalNotesSubtitle = '感受、收获，或给明天的自己留句话';
  static const journalNotesHint = '今天有什么触动？';

  static const journalStudyAvailableHint = '预估 120';

  // ── 待办操作面板 ──
  static const todoActionSchedule = '安排到时间段';
  static const todoActionFocus = '开始专注';
  static const todoActionComplete = '标为完成';
  static const todoActionDelete = '删除';

  // ── 专注 ──
  static const focusTitle = '专注';
  static const focusTaskPrompt = '今天专注哪一件事？';
  static const focusTaskHint = '写一件小事也可以';
  static const focusPickFromTodo = '从今日待办中选择';
  static String focusStartWith(int minutes) => '开始专注 $minutes 分钟';
  static const focusImmersed = '专心当下';
  static String focusRunningTask(String task) {
    final trimmed = task.trim();
    if (trimmed.isEmpty) return focusImmersed;
    return trimmed;
  }

  static const focusCompleteTitle = '完成一段专注';
  static String focusCompleteDetail(int minutes, String task) {
    final label = task.trim().isEmpty ? '番茄专注' : task.trim();
    return '$minutes 分钟 · $label';
  }

  static const focusCompleteRecord = '记入今天';
  static const focusCompleteNote = '补一句备注';
  static const focusCompleteRecorded = '这一段守住了，已记入今天';
  static String focusCompleteFeedback(int minutes) =>
      '专注了 $minutes 分钟，这一段完成了，歇一歇吧';

  static const focusBreak = '歇一歇，喝口水';
  static const focusBreakFooter = '休息结束后，继续下一轮';
  static const focusHoldToPause = '需要先停一下？长按确认';
  static const focusHolding = '好的，再按一会儿…';
  static String focusInterrupt(int count) => '刚才离开了一下（$count 次），没关系';

  // ── 睡眠 ──
  static const sleepTitle = '睡眠节奏';
  static const sleepTonightTarget = '今晚目标';
  static const sleepBedtimeLabel = '就寝';
  static const sleepWakeLabel = '起床';
  static String sleepTonightSchedule(String bed, String wake) =>
      '$bed 睡 / $wake 起';
  static String sleepHeroLine(int days) =>
      days > 0 ? '已连续早睡 $days 晚' : '今晚早点睡，也算赢一次';
  static String sleepStreakNights(int days) => '连续 $days 晚';
  static String sleepWeekProgress(int days) => '本周早睡 $days 天';

  static const sleepScheduleTitle = '今晚目标';
  static const sleepRecordTitle = '今日记录';
  static const sleepCheckInLabel = '就寝';
  static const sleepCheckInPending = '未记录';
  static const sleepWakePending = '未记录';
  static const sleepScoreLabel = '今晚得分';
  static const sleepScorePending = '待记录';

  static const sleepCheckInButton = '我准备去睡了';
  static const sleepWakeButton = '我起床了';
  static const sleepDurationLabel = '睡眠时长';
  static const sleepWakeFeedback = '早安，今天已经记下起床时间';
  static String sleepWakeRecorded(String time) => '已记录：$time';
  static const sleepNoiseTitle = '白噪音';
  static const sleepNoiseSubtitle = '选一个舒服的声音，慢慢放松';
  static const sleepNoisePlaying = '正在播放';
  static const sleepNoiseStop = '停止';

  static String sleepCheckInFeedback(int score, int streak) {
    if (score >= 10) {
      return streak > 1 ? '今晚很准时，连续 $streak 天了，身体会记住这个节奏。' : '今晚很准时，好好休息。';
    }
    if (score >= 5) {
      return '差不多准点，已经很不错了。';
    }
    return '比目标晚了一些，没关系，记录下来了就好。';
  }

  // ── 周总结 ──
  static const weeklyTitle = '一周手账';
  static const weeklyMirrorQuote = '数字只是镜子，帮你看清自己；怎么调整，只有你知道。';
  static const weeklySoulLine1 = '不是「这周表现如何」';
  static const weeklySoulLine2 = '而是「这一周，你是怎么过的」';
  static String weeklyHeader(int weekNumber, String range) =>
      '第 $weekNumber 周 · $range';
  static String weeklyAttendance(int days) => '这周记录了 $days 天';
  static const weeklyTrackTitle = '这一周的节奏';
  static const weeklyTrackJournal = '手账';
  static const weeklyTrackFocus = '专注';
  static const weeklyTrackSleep = '早睡';

  static const weeklyJournalTitle = '手账';
  static String weeklyJournalDays(int days) =>
      days > 0 ? '写了 $days 天手账' : '这周只写了 0 天';
  static String weeklyJournalDaysWarm(int days) {
    if (days == 0) return '这周还没留下手账痕迹，从今天开始也不晚';
    if (days == 1) return '这周写了 1 天，能留下痕迹就已经不错';
    return '写了 $days 天手账';
  }

  static String weeklyPlanCompare(int planned, int actual) =>
      '计划 ${_fmtMinutes(planned)} → 实际 ${_fmtMinutes(actual)}';

  static const weeklyFocusTitle = '专注';
  static String weeklyFocusSummary(int sessions, int minutes) => sessions > 0
      ? '完成 $sessions 段专注，共 ${_fmtMinutes(minutes)}'
      : '本周还没有专注记录，挑一个安静的时间开始就好';
  static String weeklyFocusPreset(int minutes) => '最常专注：$minutes 分钟段';

  static const weeklySleepTitle = '睡眠';
  static String weeklySleepEarly(int days) =>
      days > 0 ? '早睡 $days 天' : '这周还没记录睡眠，今晚开始也不晚';
  static String weeklySleepBedtime(String time) => '平均就寝 $time';
  static String weeklySleepProgress(int days) => '本周早睡 $days 天';
  static String weeklySleepStars(int stars) => '本周点亮 $stars 晚';

  static const weeklyDeltaFlat = '延续了上周的节奏';
  static const weeklyDeltaEmpty = '这周还没留下记录，慢慢来也没关系';
  static const weeklyReflectionTitle = '本周小结';
  static const weeklyReflectionSubtitle = '看完数据，留一句给下周的自己';
  static const weeklyReflectionHint = '这一周，有什么想记住的？';
  static String weeklyDeltaCompare(bool up, int delta) =>
      '比上周 ${up ? '↑' : '↓'} $delta';

  static String fmtDuration(int minutes) => _fmtMinutes(minutes);

  static String _fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m 分钟';
    if (m == 0) return '$h 小时';
    return '$h 小时 $m 分钟';
  }

  // ── 微交互 ──
  static const journalFirstTodoHint = '很好，第一步已经迈出来了';

  // ── 我的 ──
  static const profileTitle = '我的';
  static const profileWeeklySubtitle = '这一周，你是怎么过的';
  static const profileDataTitle = '数据存储';
  static const profileDataSubtitle = '所有记录都保存在本机';
  static const profileAboutTitle = '关于';
  static const profileAboutSubtitle = '时间管理手账 v1.0.2';
  static const profileSettingsTitle = '设置';
  static const profileSettingsSubtitle = '本地数据 / 主题 / 清理';
  static const profileThemeTitle = '主题';
  static const profileThemeCurrent = '纸面浅色';
  static const profileStorageTitle = '数据位置';
  static const profileStorageLocal = '仅保存在本机 SQLite';
  static const profileClearDataTitle = '清空本机数据';
  static const profileClearDataSubtitle = '删除手账、专注、睡眠和周总结记录';
  static const profileClearDataConfirmTitle = '清空所有记录？';
  static const profileClearDataConfirmBody = '这个操作会删除本机所有记录，无法撤销。';
  static const profileClearDataCancel = '再想想';
  static const profileClearDataConfirm = '确认清空';
  static const profileClearDataDone = '本机记录已清空';
}
