import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../features/common/screens/notification_screen.dart';
import '../main.dart';

bool openNotificationScreenAfterLogin = false;

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 🔹 Request permissions (iOS)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 🔹 Android channel setup ...
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.high,
    );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Notification tapped (local): ${details.payload}');
        _handleNotificationTap(details.payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 🔹 Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground message: ${message.notification?.title}');
      _showNotification(message);
    });

    // 🔹 Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 🔹 When app opened from notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 App opened via notification: ${message.data}');
      _handleNotificationTap(message.data.toString());
    });

    // ✅ 🔹 When app opened from terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('🚀 App opened from terminated state: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data.toString());
    }

    // 🔹 Print FCM Token
    final token = await _messaging.getToken();
    debugPrint('✅ FCM Token: $token');
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'No title',
      notification.body ?? 'No body',
      platformDetails,
      payload: message.data.toString(), // ✅ carry the data
    );
  }

  /// ✅ Handles navigation when notification tapped
  static void _handleNotificationTap(String? payload) {
    openNotificationScreenAfterLogin = true;
    if (navigatorKey.currentState == null) {
      debugPrint('⚠️ Navigator not ready');
      return;
    }

    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }
}

/// ✅ Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('💤 Handling background message: ${message.messageId}');
}
