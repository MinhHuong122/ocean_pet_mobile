// lib/services/NotificationService.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('⏳ [NotificationService] Initializing...');
    
    // Initialize timezone data
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 12+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Create notification channels for Android
    const channel = AndroidNotificationChannel(
      'appointment_channel',
      'Nhắc nhở lịch hẹn',
      description: 'Thông báo nhắc nhở các lịch hẹn khám thú cưng',
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('arlam'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('✅ [NotificationService] Initialized successfully');
  }

  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required String appointmentTitle,
    required String appointmentTime,
    required DateTime appointmentDateTime,
    required String reminderTime, // '1day', '3days', '1week'
  }) async {
    try {
      print('📝 [NotificationService] Scheduling reminder for: $appointmentTitle');
      print('   Appointment time: $appointmentDateTime');
      print('   Reminder type: $reminderTime');
      
      // Calculate reminder time
      DateTime reminderDateTime = appointmentDateTime;
      
      switch (reminderTime) {
        case '1day':
          reminderDateTime = appointmentDateTime.subtract(const Duration(days: 1));
          break;
        case '3days':
          reminderDateTime = appointmentDateTime.subtract(const Duration(days: 3));
          break;
        case '1week':
          reminderDateTime = appointmentDateTime.subtract(const Duration(days: 7));
          break;
        default:
          reminderDateTime = appointmentDateTime.subtract(const Duration(days: 1));
      }

      print('   Reminder will trigger at: $reminderDateTime');
      print('   Current time: ${DateTime.now()}');
      
      // Don't schedule if reminder time is in the past
      if (reminderDateTime.isBefore(DateTime.now())) {
        print('⚠️ [NotificationService] Reminder time is in the past, skipping');
        return;
      }

      // Convert to timezone-aware time
      final tz.TZDateTime tzDateTime = tz.TZDateTime.from(
        reminderDateTime,
        tz.local,
      );

      print('   Timezone: ${tzDateTime.timeZone}');
      print('   Scheduling mode: alarmClock (will bypass Do Not Disturb)');
      
      // Schedule notification
      await _notificationsPlugin.zonedSchedule(
        appointmentId,
        '🔔 Nhắc nhở lịch hẹn',
        '$appointmentTitle - $appointmentTime',
        tzDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_channel',
            'Nhắc nhở lịch hẹn',
            channelDescription: 'Thông báo nhắc nhở các lịch hẹn khám thú cưng',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            enableLights: true,
            color: const Color(0xFF8B5CF6),
            sound: const RawResourceAndroidNotificationSound('arlam'),
            ledColor: const Color(0xFF8B5CF6),
            ledOnMs: 1000,
            ledOffMs: 1000,
            fullScreenIntent: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'alarm.caf',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );

      print('✅ [NotificationService] Reminder scheduled successfully!');
      print('   ID: $appointmentId');
      print('   Will trigger in: ${reminderDateTime.difference(DateTime.now()).inMinutes} minutes');
    } catch (e) {
      print('❌ [NotificationService] Error scheduling reminder: $e');
      print('   Stack trace: ${StackTrace.current}');
    }
  }

  static Future<void> cancelAppointmentReminder(int appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId);
      print('✅ [NotificationService] Cancelled reminder for appointment: $appointmentId');
    } catch (e) {
      print('❌ [NotificationService] Error cancelling reminder: $e');
    }
  }

  static Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('✅ [NotificationService] Cancelled all reminders');
    } catch (e) {
      print('❌ [NotificationService] Error cancelling reminders: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('✅ [NotificationService] Notification tapped: ${notificationResponse.payload}');
    // Handle notification tap
  }
}
