// lib/services/NotificationService.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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

    // Initialize Workmanager for background tasks
    await Workmanager().initialize(callbackDispatcher);

    print('✅ [NotificationService] Initialized successfully');
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      if (taskName == 'appointmentReminder') {
        final String appointmentTitle = inputData?['title'] ?? 'Lịch hẹn';
        final String appointmentTime = inputData?['time'] ?? '';
        final int appointmentId = inputData?['appointmentId'] ?? 0;

        await _notificationsPlugin.show(
          appointmentId,
          '🔔 Nhắc nhở lịch hẹn',
          '$appointmentTitle - $appointmentTime',
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
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
        print('✅ [NotificationService] Appointment reminder sent for: $appointmentTitle');
      }
      return Future.value(true);
    });
  }

  static Future<void> scheduleAppointmentReminder({
    required int appointmentId,
    required String appointmentTitle,
    required String appointmentTime,
    required DateTime appointmentDateTime,
    required String reminderTime, // '1day', '3days', '1week'
  }) async {
    try {
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
      );

      // Also schedule background task
      await Workmanager().registerOneOffTask(
        'appointmentReminder_$appointmentId',
        'appointmentReminder',
        initialDelay: reminderDateTime.difference(DateTime.now()),
        inputData: {
          'appointmentId': appointmentId,
          'title': appointmentTitle,
          'time': appointmentTime,
        },
      );

      print('✅ [NotificationService] Scheduled reminder for: $appointmentTitle at ${tzDateTime.toString()}');
    } catch (e) {
      print('❌ [NotificationService] Error scheduling reminder: $e');
    }
  }

  static Future<void> cancelAppointmentReminder(int appointmentId) async {
    try {
      await _notificationsPlugin.cancel(appointmentId);
      await Workmanager().cancelByUniqueName('appointmentReminder_$appointmentId');
      print('✅ [NotificationService] Cancelled reminder for appointment: $appointmentId');
    } catch (e) {
      print('❌ [NotificationService] Error cancelling reminder: $e');
    }
  }

  static Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      await Workmanager().cancelAll();
      print('✅ [NotificationService] Cancelled all reminders');
    } catch (e) {
      print('❌ [NotificationService] Error cancelling reminders: $e');
    }
  }

  static Future<void> showTestNotification() async {
    try {
      await _notificationsPlugin.show(
        0,
        '🔔 Thử nghiệm thông báo',
        'Đây là thông báo thử nghiệm từ ứng dụng Pet Care',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Thử nghiệm',
            channelDescription: 'Thông báo thử nghiệm',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            enableLights: true,
            color: const Color(0xFF8B5CF6),
            sound: const RawResourceAndroidNotificationSound('arlam'),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      print('✅ [NotificationService] Test notification sent');
    } catch (e) {
      print('❌ [NotificationService] Error sending test notification: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('✅ [NotificationService] Notification tapped: ${notificationResponse.payload}');
    // Handle notification tap
  }
}
