import 'package:firebase_messaging/firebase_messaging.dart';
// REMOVED duplicate alias import for firebase_messaging to avoid conflict
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expenxo/models/notification_model.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    await _persistNotification(message.notification!);
  }
}

Future<void> _persistNotification(RemoteNotification notification) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add(
            NotificationModel(
              id: '',
              title: notification.title ?? 'Notification',
              body: notification.body ?? '',
              timestamp: DateTime.now(),
              type: 'info', // Default type for external push notifications
            ).toMap(),
          );
    }
  } catch (e) {
    if (kDebugMode) print("Error persisting notification: $e");
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Make this nullable and do NOT instantiate it immediately
  fln.FlutterLocalNotificationsPlugin? _localNotifications;

  Future<void> initialize() async {
    // 1. Initialize Timezones (Mobile only usually, or safe to skip if web issues)
    if (!kIsWeb) {
      try {
        tz.initializeTimeZones();
      } catch (e) {
        if (kDebugMode) print("Timezone init error: $e");
      }
    }

    // 2. Initialize Local Notifications (Skip on Web to avoid errors)
    if (!kIsWeb) {
      _localNotifications = fln.FlutterLocalNotificationsPlugin();
      const fln.AndroidInitializationSettings initializationSettingsAndroid =
          fln.AndroidInitializationSettings('@mipmap/launcher_icon');

      const fln.DarwinInitializationSettings initializationSettingsDarwin =
          fln.DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final fln.InitializationSettings initializationSettings =
          fln.InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      try {
        await _localNotifications?.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (details) {
            if (kDebugMode) print("Notification Tapped: ${details.payload}");
          },
        );
      } catch (e) {
        if (kDebugMode) print("LocalNotifications init error: $e");
      }

      // 3. Request Permissions (Android & iOS)
      try {
        // Android 13+
        final androidImplementation = _localNotifications
            ?.resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission();
        }

        // iOS (Explicit request if needed, though usually handled by init settings above)
        final iosImplementation = _localNotifications
            ?.resolvePlatformSpecificImplementation<
              fln.IOSFlutterLocalNotificationsPlugin
            >();
        if (iosImplementation != null) {
          await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      } catch (e) {
        if (kDebugMode) print("Permission request error: $e");
      }
    }

    // 4. Firebase Permission (Works on Web too)
    try {
      await _firebaseMessaging.requestPermission();
    } catch (e) {
      if (kDebugMode) print("Firebase permission error: $e");
    }

    // 5. Background Handler (Skip on Web)
    if (!kIsWeb) {
      try {
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      } catch (e) {
        if (kDebugMode) print("Background handler error: $e");
      }
    }

    // 6. Foreground Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      // Fixed: Removed 'fln.' prefix as AndroidNotification comes from firebase_messaging
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        // Show Local Notification ONLY if not Web and initialized
        if (!kIsWeb && android != null && _localNotifications != null) {
          showLocalNotification(
            title: notification.title ?? 'Notification',
            body: notification.body ?? '',
          );
        }

        // Persist to Firestore
        _persistNotification(notification);
      }
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || _localNotifications == null) return;

    try {
      const fln.AndroidNotificationDetails androidDetails =
          fln.AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
          );

      const fln.NotificationDetails notificationDetails =
          fln.NotificationDetails(
            android: androidDetails,
            iOS: fln.DarwinNotificationDetails(),
          );

      await _localNotifications?.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) print("Error showing notification: $e");
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb || _localNotifications == null) return;

    try {
      await _localNotifications?.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const fln.NotificationDetails(
          android: fln.AndroidNotificationDetails(
            'scheduled_channel',
            'Scheduled Notifications',
            importance: fln.Importance.max,
            priority: fln.Priority.high,
          ),
        ),
        androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: fln.DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      if (kDebugMode) print("Error scheduling notification: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb || _localNotifications == null) return;
    try {
      await _localNotifications?.cancel(id);
    } catch (e) {
      if (kDebugMode) print("Error cancelling notification: $e");
    }
  }
}
