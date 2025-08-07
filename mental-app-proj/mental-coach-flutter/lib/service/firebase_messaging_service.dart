import 'dart:io' show Platform;
import 'package:color_simp/color_simp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mental_coach_flutter_firebase/main.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart'; // להוסיף תלות ל-HTTP

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message received: ${message.notification?.title}");
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    NotificationDetails(
      android: const AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    ),
  );
}

class FirebaseMessagingService {
  static Future<void> initialize() async {
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(provisional: true);
    print("Notification settings: $notificationSettings");

    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'default_channel',
        'Default Channel',
        description: 'ערוץ ברירת מחדל להתראות',
        importance: Importance.high,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    print("FCM Auto-Init enabled");

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");
    if (fcmToken != null && FirebaseAuth.instance.currentUser != null) {
      await _sendTokenToServer(fcmToken); // שליחת הטוקן לשרת
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            "${message.notification?.title ?? 'הודעה חדשה'}: ${message.notification?.body ?? ''}",
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print("Token refreshed: $fcmToken");
      await _sendTokenToServer(fcmToken); // עדכון הטוקן בשרת כשהוא משתנה
    }).onError((err) {
      print("Error getting token: $err");
    });

    // אופציונלי: רישום ל-Topic "all" לשליחה לכל המשתמשים
    await FirebaseMessaging.instance.subscribeToTopic('all');
  }

  static Future<void> _sendTokenToServer(String token) async {
    "inside send token to server".blue.log();
    try {
      final response = await AppFetch.fetch('/pushMessages/update-token',
          method: 'POST',
          headers: {
            'Custom-Header': 'Value'
          },
          body: {
            'fcmToken': token,
          });

      if (response.statusCode == 200) {
        print("Token sent to server successfully");
      } else {
        print("Failed to send token: ${response.statusCode}");
      }

      // Continue execution despite the error
    } on Exception catch (ex) {
      // Additional catch for specific exceptions
      print("Exception in token registration: $ex");
    } catch (unknown) {
      // Fallback for any other errors
      print("Unknown error during token registration");
    } finally {
      // This ensures the method completes even if there's an error
      print("Token registration process completed");
    }
    // Function will always return successfully
  }
}
