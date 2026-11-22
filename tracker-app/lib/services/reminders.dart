import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily study reminder plus a "streak at risk" nudge in the evening.
class Reminders {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _dailyId = 1;
  static const _streakId = 2;

  /// Hour at which the streak nudge fires if nothing was done that day.
  static const streakNudgeHour = 21;
  static const streakNudgeMinute = 30;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'study_reminders',
      'Study reminders',
      channelDescription: 'Daily reminder for the roadmap plan',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> init() async {
    if (!_supported) return;
    tzdata.initializeTimeZones();
    // Hyderabad. The plan and the reminders are all local to IST.
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  Future<bool> requestPermission() async {
    if (!_supported) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> schedule({
    required bool enabled,
    required int minutesOfDay,
    required String title,
    required String body,
    required int streak,
    required bool doneToday,
  }) async {
    if (!_ready) return;
    await _plugin.cancel(id: _dailyId);
    await _plugin.cancel(id: _streakId);
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var daily = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesOfDay ~/ 60,
      minutesOfDay % 60,
    );
    if (!daily.isAfter(now)) daily = daily.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: _dailyId,
      title: title,
      body: body,
      scheduledDate: daily,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Only nudge when there's a streak to lose and nothing done yet today.
    final nudge = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      streakNudgeHour,
      streakNudgeMinute,
    );
    if (streak > 0 && !doneToday && nudge.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: _streakId,
        title: 'Your $streak-day streak ends at midnight',
        body: 'Tick one task to keep it. Even 20 minutes counts.',
        scheduledDate: nudge,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
