// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:zeta_ess/services/secure_stroage_service.dart';
//
// import '../core/api_constants/keys/storage_keys.dart';
//
// class FirebaseNotificationService {
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//
//   static Future<void> initialize() async {
//     await _messaging.requestPermission();
//     await _getToken();
//     _setupOnMessageHandler();
//   }
//
//   static Future<void> _getToken() async {
//     final token = await _messaging.getToken();
//     SecureStorageService.write(
//       key: StorageKeys.fcmKey,
//       value: token ?? 'noToken',
//     );
//   }
//
//   static void _setupOnMessageHandler() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint(
//         "📩 Message received in foreground: ${message.notification?.title}",
//       );
//
//       // You can show an alert/snackbar here if needed.
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint("🔔 Notification tapped: ${message.data}");
//     });
//   }
// }
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import '../core/api_constants/keys/storage_keys.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission first
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken;
      // Get APNS token first (iOS only)
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          print('APNS Token: $apnsToken');
          fcmToken = await _firebaseMessaging.getToken();
          print('FCM Token: $fcmToken');
        } else {
          await Future.delayed(Duration(seconds: 2));
          apnsToken = await _firebaseMessaging.getAPNSToken();
        }
      } else {
        // For Android, directly get FCM token
        fcmToken = await _firebaseMessaging.getToken();
      }
      SecureStorageService.write(
        key: StorageKeys.fcmKey,
        value: fcmToken ?? 'noToken',
      );
    }
  }
}
