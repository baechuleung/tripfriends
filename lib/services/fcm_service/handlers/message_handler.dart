// lib/services/fcm_service/handlers/message_handler.dart
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/android_config.dart';
import '../config/ios_config.dart';
import 'chat_handler.dart';
import 'match_handler.dart';
import 'approval_handler.dart';  // ApprovalHandler import 추가

// 앱 라이프사이클 변화 감지를 위한 옵저버 클래스
class AppLifecycleObserver extends WidgetsBindingObserver {
  final Function? onResumed;
  final Function? onPaused;

  AppLifecycleObserver({this.onResumed, this.onPaused});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (onResumed != null) onResumed!();
        break;
      case AppLifecycleState.paused:
        if (onPaused != null) onPaused!();
        break;
      default:
        break;
    }
  }
}

// 전역 내비게이터 키 (앱 어디서나 내비게이션 접근 가능)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 전역 백그라운드 핸들러
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // 백그라운드 메시지 수신 시 처리 로직
  print('🔔 백그라운드 메시지 수신: ${message.notification?.title}');
  // 백그라운드에서는 앱이 실행되지 않은 상태이므로 최소한의 처리만 수행
}

class MessageHandler {
  // 외부에서 접근 가능한 백그라운드 핸들러
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    await firebaseBackgroundMessageHandler(message);
  }

  // 알림 설정
  static Future<void> setupMessageHandlers() async {
    print('🔔 메시지 핸들러 설정 시작');

    // FCM 권한 요청 (iOS에서 필요)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('🔔 FCM 알림 권한 상태: ${settings.authorizationStatus}');

    // 앱이 포그라운드 상태일 때 알림 표시 설정 (iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 포그라운드 알림 핸들러 등록
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 [onMessage] 포그라운드 메시지 수신: ${message.notification?.title}');
      print('🔍 [onMessage] 메시지 데이터: ${message.data}');
      handleForegroundMessage(message);
    });

    // 앱이 백그라운드에서 열릴 때 핸들러 등록
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 [onMessageOpenedApp] 알림을 통해 앱 열림: ${message.notification?.title}');
      print('🔍 [onMessageOpenedApp] 메시지 데이터: ${message.data}');

      // 앱 뱃지 초기화
      resetBadgeCount();

      if (message.data.isNotEmpty) {
        print('👆 알림 클릭 처리 시작 (onMessageOpenedApp)');
        handleNotificationClick(message.data);
      }
    });

    // 앱이 종료된 상태에서 알림으로 열린 경우 처리
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('🔔 [initialMessage] 종료 상태에서 알림으로 앱 실행됨: ${initialMessage.notification?.title}');
      print('🔍 [initialMessage] 초기 메시지 데이터: ${initialMessage.data}');

      // 앱 뱃지 초기화
      resetBadgeCount();

      if (initialMessage.data.isNotEmpty) {
        // 약간의 지연 후 처리 (앱 초기화 시간 확보)
        Future.delayed(const Duration(seconds: 2), () {
          print('👆 알림 클릭 처리 시작 (initialMessage)');
          handleNotificationClick(initialMessage.data);
        });
      }
    } else {
      print('⚠️ 초기 메시지 없음');
    }

    print('✅ 메시지 핸들러 설정 완료');
  }

  // 알림 탭 핸들러
  static void onNotificationResponse(NotificationResponse response) {
    // 알림 클릭 시 처리 로직
    print('👆 [onNotificationResponse] 알림 클릭됨: ${response.payload}');

    // 앱 뱃지 초기화
    resetBadgeCount();

    // 페이로드가 있으면 파싱
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        Map<String, dynamic> data = json.decode(response.payload!);
        print('👆 파싱된 알림 데이터: $data');
        handleNotificationClick(data);
      } catch (e) {
        print('⚠️ 알림 페이로드 파싱 실패: $e');
      }
    }
  }

  // 앱 뱃지 초기화 메서드 추가
  static Future<void> resetBadgeCount() async {
    print('🔢 앱 뱃지 초기화 시작');
    try {
      if (Platform.isIOS) {
        // iOS에서는 로컬 알림 플러그인을 통해 뱃지 초기화
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.cancelAll(); // 모든 알림 취소

        // 빈 알림을 표시하되 badgeNumber를 0으로 설정하여 뱃지 초기화
        IOSConfig.flutterLocalNotificationsPlugin.show(
          0,
          '', // 빈 제목
          '', // 빈 내용
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
              badgeNumber: 0, // 뱃지 숫자를 0으로 설정
              presentAlert: false, // 알림 자체는 표시하지 않음
              presentBadge: true,
              presentSound: false,
            ),
          ),
        );

        print('✅ iOS 앱 뱃지 초기화 완료');
      } else if (Platform.isAndroid) {
        // Android에서는 로컬 알림 플러그인을 통해 뱃지 초기화
        await AndroidConfig.flutterLocalNotificationsPlugin.cancelAll();
        print('✅ Android 알림 및 뱃지 초기화 완료');
      }
    } catch (e) {
      print('⚠️ 앱 뱃지 초기화 실패: $e');
    }
  }

  // 알림 클릭 처리
  static void handleNotificationClick(Map<String, dynamic> data) {
    // 알림 타입에 따른 처리
    String? type = data['type'];
    print('👆 알림 클릭 처리: 타입=$type, 데이터=$data');

    // NavigatorKey 상태 확인
    print('🔍 NavigatorKey 상태: ${navigatorKey.currentState != null ? "사용 가능" : "사용 불가"}');

    // 내비게이터 상태가 없으면 약간의 지연 후 다시 시도
    if (navigatorKey.currentState == null) {
      print('⚠️ 내비게이터 상태가 없습니다. 1초 후 재시도합니다.');
      Future.delayed(const Duration(seconds: 1), () {
        // 다시 내비게이터 상태 확인
        if (navigatorKey.currentState != null) {
          _processNotificationClick(type, data);
        } else {
          print('⚠️ 내비게이터 상태가 여전히 없습니다. 3초 후 마지막으로 재시도합니다.');
          // 마지막으로 한 번 더 시도
          Future.delayed(const Duration(seconds: 3), () {
            _processNotificationClick(type, data);
          });
        }
      });
    } else {
      _processNotificationClick(type, data);
    }
  }

  // 실제 알림 클릭 처리 로직 (내비게이터 상태 확인 후 호출)
  static void _processNotificationClick(String? type, Map<String, dynamic> data) {
    print('🔍 알림 처리 시작: type=$type');

    switch(type) {
      case 'new_match_request':
        print('🔍 매치 요청 알림 처리 시작');
        MatchHandler.handleMatchRequest(data);
        break;

      case 'message':
        print('🔍 채팅 메시지 알림 처리 시작');
        ChatHandler.handleChatMessage(data);
        break;

      case 'approval_reason_update':
        print('🔍 승인 사유 업데이트 알림 처리 시작');
        ApprovalHandler.handleApprovalUpdate(data);
        break;

      default:
        print('📋 기본 화면으로 이동 - 타입: $type');
    // 기본 화면으로 이동 로직
    }
  }

  // 포그라운드 메시지 처리
  static void handleForegroundMessage(RemoteMessage message) {
    print('🔔 [handleForegroundMessage] 포그라운드 메시지 수신: ${message.notification?.title}');
    print('🔍 [handleForegroundMessage] 메시지 데이터: ${message.data}');

    // Android에서는 모든 메시지에 대해 로컬 알림 생성
    // iOS에서는 notification이 null인 경우에만 로컬 알림 생성 (기존 동작 유지)
    if (Platform.isAndroid || (Platform.isIOS && message.notification == null)) {
      if (message.data.isNotEmpty) {
        showLocalNotification(message);
      }
    }

    // 메시지 타입에 따른 추가 처리
    if (message.data.containsKey('type')) {
      String type = message.data['type'] ?? '';

      if (type == 'message') {
        ChatHandler.processChatMessage(message.data);
      } else if (type == 'new_match_request') {
        MatchHandler.processMatchRequest(message.data);
      } else if (type == 'approval_reason_update') {
        ApprovalHandler.processApprovalUpdate(message.data);
      }
    }
  }

  // 로컬 알림 표시
  static void showLocalNotification(RemoteMessage message) {
    // 데이터에서 제목과 내용 추출
    String title = message.data['title'] ?? message.notification?.title ?? '새 알림';
    String body = message.data['body'] ?? message.notification?.body ?? '';

    print('📱 로컬 알림 생성: 플랫폼=${Platform.isAndroid ? "Android" : "iOS"}, 제목=$title, 내용=$body');
    print('📱 데이터 페이로드: ${json.encode(message.data)}');

    // Android 로컬 알림 표시
    if (Platform.isAndroid) {
      // AndroidConfig.channel이 null인지 확인
      if (AndroidConfig.channel == null) {
        print('⚠️ Android 알림 채널이 초기화되지 않았습니다.');
        return;
      }

      try {
        AndroidConfig.flutterLocalNotificationsPlugin.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              AndroidConfig.channel!.id,
              AndroidConfig.channel!.name,
              channelDescription: AndroidConfig.channel!.description,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              enableVibration: true,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: json.encode(message.data),
        );
        print('✅ Android 로컬 알림 생성 성공');
      } catch (e) {
        print('⚠️ Android 로컬 알림 생성 실패: $e');
      }
    }
    // iOS 로컬 알림 표시
    else if (Platform.isIOS) {
      // 로컬 알림 표시를 위한 플러그인 인스턴스 직접 생성
      FlutterLocalNotificationsPlugin().show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        payload: json.encode(message.data),
      );
      print('✅ iOS 로컬 알림 생성 성공');
    }
  }
}