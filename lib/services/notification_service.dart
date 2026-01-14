import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fln;
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
  final fln.FlutterLocalNotificationsPlugin _localNotifications =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.DarwinInitializationSettings initializationSettingsDarwin =
        fln.DarwinInitializationSettings();

    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) print("Notification Tapped: ${details.payload}");
        // Optional: Navigate to NotificationPage
      },
    );

    // Platform specific permission for Android 13+
    final platform = _localNotifications
        .resolvePlatformSpecificImplementation<
          fln.AndroidFlutterLocalNotificationsPlugin
        >();
    if (platform != null) {
      await platform.requestNotificationsPermission();
    }

    await _firebaseMessaging.requestPermission();

    // Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      fln.AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        // Show Local Notification
        showLocalNotification(
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
        );

        // Persist to Firestore so it shows in the list
        _persistNotification(notification);
      }
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const fln.AndroidNotificationDetails androidDetails =
        fln.AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        );

    const fln.NotificationDetails notificationDetails = fln.NotificationDetails(
      android: androidDetails,
      iOS: fln.DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _localNotifications.zonedSchedule(
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
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
