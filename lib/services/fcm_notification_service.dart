import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler (khi app bị tắt hoặc tối thiểu)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Background message: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
}

class FCMNotificationService {
  static final FCMNotificationService _instance = FCMNotificationService._internal();

  factory FCMNotificationService() {
    return _instance;
  }

  FCMNotificationService._internal();

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// Notification channel cho Android
  late AndroidNotificationChannel _channel;

  /// Khởi tạo FCM notification service
  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Tạo notification channel cho Android
    _channel = const AndroidNotificationChannel(
      'pet_high_importance', // id
      'Thông báo thú cưng',  // tên
      description: 'Thông báo lịch khám, nhắc nhở, sự kiện thú cưng',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Tạo channel trên thiết bị Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Thiết lập cách hiển thị thông báo khi app đang mở (foreground)
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Bắt background message
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Khởi tạo local notifications
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    print("✅ FCM Notification Service initialized");
  }

  /// Lấy FCM Token (dùng để gửi thông báo từ server)
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("🔑 FCM Token: $token");
      return token;
    } catch (e) {
      print("❌ Lỗi lấy FCM Token: $e");
      return null;
    }
  }

  /// Xử lý khi nhân thông báo khi app đang mở (foreground)
  void listenForForegroundMessages(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📱 Foreground message received: ${message.messageId}");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Hiển thị local notification
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              importance: Importance.high,
              priority: Priority.high,
              ongoing: false,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }

      // Gọi callback khi nhận thông báo
      onMessage(message);
    });
  }

  /// Xử lý khi nhấn vào thông báo (kể cả khi app bị tắt)
  void listenForMessageOpenedApp(
    Function(RemoteMessage) onMessageOpenedApp,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("👆 Notification tapped: ${message.data}");
      onMessageOpenedApp(message);
    });

    // Kiểm tra xem app được mở từ thông báo không
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("🚀 App opened from notification: ${message.data}");
        onMessageOpenedApp(message);
      }
    });
  }

  /// Callback khi người dùng nhấn vào local notification
  void _onNotificationTap(NotificationResponse response) {
    print("📌 Local notification tapped: ${response.payload}");
    // Xử lý điều hướng dựa vào payload
  }

  /// Gửi thông báo local test (không cần server)
  Future<void> sendTestNotification({
    required String title,
    required String body,
    required String notificationType, // 'appointment', 'reminder', 'event', etc.
  }) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch.hashCode & 0x7FFFFFFF;

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: notificationType,
      );

      print("✅ Test notification sent: $title");
    } catch (e) {
      print("❌ Lỗi gửi test notification: $e");
    }
  }

  /// Hủy FCM subscription
  Future<void> dispose() async {
    // Có thể thêm logic cleanup nếu cần
  }
}

/// Helper class để quản lý các loại thông báo khác nhau
class NotificationHelper {
  /// Thông báo lịch hẹn
  static Future<void> sendAppointmentReminder({
    required String petName,
    required String appointmentType, // 'tiêm chủng', 'khám sức khỏe', etc.
    required DateTime appointmentDate,
  }) async {
    final fcm = FCMNotificationService();
    final dateStr = "${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}";

    await fcm.sendTestNotification(
      title: "📅 Nhắc nhở lịch hẹn",
      body: "$petName cần $appointmentType vào $dateStr",
      notificationType: 'appointment',
    );
  }

  /// Thông báo sự kiện
  static Future<void> sendEventNotification({
    required String eventName,
    required String eventDescription,
    required DateTime eventDate,
  }) async {
    final fcm = FCMNotificationService();
    final timeStr = "${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}";

    await fcm.sendTestNotification(
      title: "🎉 Sự kiện thú cưng",
      body: "$eventName lúc $timeStr - $eventDescription",
      notificationType: 'event',
    );
  }

  /// Thông báo sức khỏe
  static Future<void> sendHealthNotification({
    required String petName,
    required String healthAlert,
  }) async {
    final fcm = FCMNotificationService();

    await fcm.sendTestNotification(
      title: "❤️ Cảnh báo sức khỏe",
      body: "$petName: $healthAlert",
      notificationType: 'health',
    );
  }

  /// Thông báo tin lạc thú cưng
  static Future<void> sendLostPetNotification({
    required String petName,
    required String location,
    required String description,
  }) async {
    final fcm = FCMNotificationService();

    await fcm.sendTestNotification(
      title: "🐾 Tìm thấy thú cưng",
      body: "Có người phát hiện $petName ở $location - $description",
      notificationType: 'lost_pet',
    );
  }

  /// Thông báo cộng đồng
  static Future<void> sendCommunityNotification({
    required String postTitle,
    required String userName,
  }) async {
    final fcm = FCMNotificationService();

    await fcm.sendTestNotification(
      title: "💬 Bài viết mới từ cộng đồng",
      body: "$userName: $postTitle",
      notificationType: 'community',
    );
  }

  /// Thông báo nhắc nhở hàng ngày
  static Future<void> sendDailyReminder({
    required String petName,
    required String reminderType, // 'cho ăn', 'tắm', 'chơi', etc.
  }) async {
    final fcm = FCMNotificationService();

    await fcm.sendTestNotification(
      title: "⏰ Nhắc nhở hàng ngày",
      body: "Đến lúc $reminderType cho $petName rồi!",
      notificationType: 'reminder',
    );
  }
}
