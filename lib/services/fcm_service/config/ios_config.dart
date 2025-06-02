// lib/services/fcm_service/config/ios_config.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../handlers/message_handler.dart';

class IOSConfig {
  // 로컬 알림 플러그인
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // iOS 알림 초기화 설정
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentSound: true,
      // 알림 자동 삭제 방지
      requestCriticalPermission: true, // 중요 알림 요청
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: MessageHandler.onNotificationResponse,
    );
  }
}