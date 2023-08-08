import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('justwater');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            channelDescription: 'description',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true));
  }

  Future<void> showNotification(
      {required int id, required String? title, required String? body}) async {
    print("showNotification called");
    await flutterLocalNotificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future selectNotification(String? payload) async {
    //Handle notification tapped logic here
  }
}
