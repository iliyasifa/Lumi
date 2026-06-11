import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final DateTime _appLaunchTime = DateTime.now();
  final Set<String> _seenNotificationIds = {};
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  Future<void> initialize() async {
    try {
      // 1. Request FCM permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('User granted notification permission: ${settings.authorizationStatus}');
      }

      // 2. Initialize local notifications
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
      );

      await _localNotificationsPlugin.initialize(
        settings: initSettings,
      );

      // Create Android Notification Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'lumi_notifications',
        'Lumi Notifications',
        description: 'Real-time activity and push notifications on Lumi',
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Setup Firebase Messaging Foreground handlers
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          _showLocalNotification(
            id: notification.hashCode,
            title: notification.title ?? '',
            body: notification.body ?? '',
          );
        }
      });
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Update user's FCM token in Firestore and start Firestore notifications listener
  Future<void> onUserLogin(String uid) async {
    try {
      // Fetch FCM Token
      String? token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }

      // Start listening for new notifications in Firestore to display locally in system tray
      _firestoreSubscription?.cancel();
      _firestoreSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null) continue;

            final notificationId = data['notificationId'] as String? ?? '';
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final senderId = data['senderId'] as String? ?? '';

            if (notificationId.isNotEmpty &&
                senderId != uid &&
                timestamp != null &&
                timestamp.isAfter(_appLaunchTime) &&
                !_seenNotificationIds.contains(notificationId)) {
              
              _seenNotificationIds.add(notificationId);
              
              _showLocalNotification(
                id: notificationId.hashCode,
                title: _getNotificationTitle(data['type'] as String? ?? ''),
                body: _getNotificationBody(data),
              );
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error handling login in notification service: $e');
    }
  }

  /// Stop listening on logout
  void onUserLogout() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'like':
        return 'New Like';
      case 'comment':
        return 'New Comment';
      case 'follow':
        return 'New Follower';
      default:
        return 'Lumi Notification';
    }
  }

  String _getNotificationBody(Map<String, dynamic> data) {
    final username = data['senderUsername'] as String? ?? 'Someone';
    final type = data['type'] as String? ?? '';
    
    switch (type) {
      case 'like':
        return '$username liked your post.';
      case 'comment':
        final comment = data['commentText'] as String? ?? '';
        final displayComment = comment.length > 30 ? '${comment.substring(0, 30)}...' : comment;
        return '$username commented: "$displayComment"';
      case 'follow':
        return '$username started following you.';
      default:
        return '$username interacted with your profile.';
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'lumi_notifications',
      'Lumi Notifications',
      channelDescription: 'Real-time activity and push notifications on Lumi',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }
}
