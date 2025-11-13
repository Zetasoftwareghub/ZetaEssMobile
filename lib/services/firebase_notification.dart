import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../features/common/screens/notification_screen.dart';
import '../main.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // static Future<void> initialize() async {
  //   RemoteMessage? initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();
  //
  //   if (initialMessage != null) {
  //     debugPrint('🚀 App opened from terminated state: ${initialMessage.data}');
  //     _handleNotificationTap(initialMessage.data.toString());
  //   }
  //
  //   // 🔹 Request permissions (iOS)
  //   await _messaging.requestPermission(alert: true, badge: true, sound: true);
  //
  //   // 🔹 Android notification channel
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'high_importance_channel',
  //     'High Importance Notifications',
  //     description: 'Used for important notifications.',
  //     importance: Importance.high,
  //   );
  //
  //   // 🔹 Initialize local notifications
  //   const AndroidInitializationSettings androidSettings =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //
  //   const DarwinInitializationSettings iosSettings =
  //       DarwinInitializationSettings();
  //
  //   final InitializationSettings initSettings = InitializationSettings(
  //     android: androidSettings,
  //     iOS: iosSettings,
  //   );
  //
  //   await _localNotifications.initialize(
  //     initSettings,
  //     onDidReceiveNotificationResponse: (details) {
  //       debugPrint('🔔 Notification tapped (local): ${details.payload}');
  //       _handleNotificationTap(details.payload);
  //     },
  //   );
  //
  //   // 🔹 Create the channel (Android)
  //   await _localNotifications
  //       .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin
  //       >()
  //       ?.createNotificationChannel(channel);
  //
  //   // 🔹 Foreground messages
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     debugPrint('📩 Foreground message: ${message.notification?.title}');
  //     _showNotification(message);
  //   });
  //
  //   // 🔹 Background messages
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  //   // 🔹 When app opened from notification tap
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     debugPrint('📲 App opened via notification: ${message.data}');
  //     _handleNotificationTap(message.data.toString());
  //   });
  //
  //   // 🔹 Print the FCM Token
  //   final token = await _messaging.getToken();
  //   debugPrint('✅ FCM Token: $token');
  // }
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

// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:zeta_ess/services/secure_stroage_service.dart';
// //
// // import '../core/api_constants/keys/storage_keys.dart';
// //
// // class FirebaseNotificationService {
// //   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
// //
// //   static Future<void> initialize() async {
// //     await _messaging.requestPermission();
// //     await _getToken();
// //     _setupOnMessageHandler();
// //   }
// //
// //   static Future<void> _getToken() async {
// //     final token = await _messaging.getToken();
// //     SecureStorageService.write(
// //       key: StorageKeys.fcmKey,
// //       value: token ?? 'noToken',
// //     );
// //   }
// //
// //   static void _setupOnMessageHandler() {
// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //       debugPrint(
// //         "📩 Message received in foreground: ${message.notification?.title}",
// //       );
// //
// //       // You can show an alert/snackbar here if needed.
// //     });
// //
// //     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// //       debugPrint("🔔 Notification tapped: ${message.data}");
// //     });
// //   }
// // }
// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:zeta_ess/services/secure_stroage_service.dart';
//
// import '../core/api_constants/keys/storage_keys.dart';
//
// class FirebaseNotificationService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;
//
//   static Future<void> initialize() async {
//     // Request permission first
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       String? fcmToken;
//       // Get APNS token first (iOS only)
//       if (Platform.isIOS) {
//         String? apnsToken = await _firebaseMessaging.getAPNSToken();
//         if (apnsToken != null) {
//           print('APNS Token: $apnsToken');
//           fcmToken = await _firebaseMessaging.getToken();
//           print('FCM Token: $fcmToken');
//         } else {
//           await Future.delayed(Duration(seconds: 2));
//           apnsToken = await _firebaseMessaging.getAPNSToken();
//         }
//       } else {
//         // For Android, directly get FCM token
//         fcmToken = await _firebaseMessaging.getToken();
//       }
//       SecureStorageService.write(
//         key: StorageKeys.fcmKey,
//         value: fcmToken ?? 'noToken',
//       );
//     }
//   }
// }
