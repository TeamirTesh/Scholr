import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scholr/models/task_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: DarwinInitializationSettings());
    await _local.initialize(settings: settings);

    FirebaseMessaging.onMessage.listen((message) async {
      await _local.show(
        id: message.hashCode,
        title: message.notification?.title ?? 'Scholr',
        body: message.notification?.body ?? 'New update',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('scholr_main', 'Scholr Notifications', importance: Importance.max),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> scheduleDueSoonReminder(TaskModel task) async {
    final diff = task.deadline.difference(DateTime.now());
    if (diff.inHours > 24 || diff.isNegative) return;

    await _local.show(
      id: task.id.hashCode,
      title: 'Task due soon: ${task.title}',
      body: '${task.course} is due in ${diff.inHours}h',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('scholr_tasks', 'Task Reminders', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
