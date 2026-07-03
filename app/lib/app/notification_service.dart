import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class FocusNotificationScheduler {
  Future<void> initialize();
  Future<void> requestPermissions();
  Future<void> scheduleFocusEnd(DateTime when, String task);
  Future<void> scheduleBreakEnd(DateTime when);
  Future<void> cancelFocusNotifications();
}

final focusNotificationSchedulerProvider = Provider<FocusNotificationScheduler>(
  (ref) {
    return LocalNotificationService.instance;
  },
);

class LocalNotificationService implements FocusNotificationScheduler {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const int _focusEndId = 1001;
  static const int _breakEndId = 1002;
  static const String _channelId = 'focus_timer';
  static const String _channelName = '专注提醒';
  static const String _channelDescription = '番茄钟和休息结束提醒';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('ic_stat_timer');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> scheduleFocusEnd(DateTime when, String task) async {
    final label = task.trim().isEmpty ? '这段专注' : task.trim();
    await _schedule(
      id: _focusEndId,
      when: when,
      title: '专注完成了',
      body: '$label 已经守住，记得休息一下。',
    );
  }

  @override
  Future<void> scheduleBreakEnd(DateTime when) {
    return _schedule(
      id: _breakEndId,
      when: when,
      title: '休息结束了',
      body: '喝口水，准备进入下一段专注。',
    );
  }

  @override
  Future<void> cancelFocusNotifications() async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(id: _focusEndId);
    await _plugin.cancel(id: _breakEndId);
  }

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await initialize();
    final scheduledAt = when.isAfter(DateTime.now())
        ? when
        : DateTime.now().add(const Duration(seconds: 1));
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
