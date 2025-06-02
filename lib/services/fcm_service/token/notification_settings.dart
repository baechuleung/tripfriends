// lib/services/fcm_service/token/notification_settings.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared_preferences_service.dart';

class NotificationSettings {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 특정 토픽 구독
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('✅ 토픽 구독 완료: $topic');
  }

  // 토픽 구독 해제
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('🗑️ 토픽 구독 해제 완료: $topic');
  }

  // 알림 설정 관리
  static Future<void> updateSettings({
    bool enableMatchRequests = true,
    bool enableMessages = true,
    bool enablePromotions = true,
  }) async {
    try {
      // 사용자 설정 저장
      await SharedPreferencesService.setBool('notification_match_requests', enableMatchRequests);
      await SharedPreferencesService.setBool('notification_messages', enableMessages);
      await SharedPreferencesService.setBool('notification_promotions', enablePromotions);

      // 토픽 구독 관리
      if (enableMatchRequests) {
        await subscribeToTopic('match_requests');
      } else {
        await unsubscribeFromTopic('match_requests');
      }

      if (enablePromotions) {
        await subscribeToTopic('promotions');
      } else {
        await unsubscribeFromTopic('promotions');
      }

      // 현재 로그인한 사용자가 있다면 Firestore에도 설정 저장
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('tripfriends_users')
            .doc(currentUser.uid)
            .update({
          'notification_settings': {
            'match_requests': enableMatchRequests,
            'messages': enableMessages,
            'promotions': enablePromotions,
            'updated_at': FieldValue.serverTimestamp(),
          }
        });
      }

      print('✅ 알림 설정 업데이트 완료');
    } catch (e) {
      print('⚠️ 알림 설정 업데이트 실패: $e');
    }
  }

  // 모든 알림 비활성화
  static Future<void> disableAllNotifications() async {
    try {
      // 모든 토픽 구독 해제
      await unsubscribeFromTopic('match_requests');
      await unsubscribeFromTopic('promotions');

      // 설정 업데이트
      await updateSettings(
        enableMatchRequests: false,
        enableMessages: false,
        enablePromotions: false,
      );

      print('🔕 모든 알림 비활성화 완료');
    } catch (e) {
      print('⚠️ 모든 알림 비활성화 실패: $e');
    }
  }

  // 특정 채팅방에 대한 알림 활성화/비활성화
  static Future<void> updateChatSettings(String chatId, bool enabled) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      if (enabled) {
        await subscribeToTopic('chat_$chatId');
      } else {
        await unsubscribeFromTopic('chat_$chatId');
      }

      // Firestore에 설정 저장
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'user_id': currentUser.uid,
        'chat_id': chatId,
        'notifications_enabled': enabled,
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ 채팅방 알림 설정 업데이트 완료: $chatId, 활성화=$enabled');
    } catch (e) {
      print('⚠️ 채팅방 알림 설정 업데이트 실패: $e');
    }
  }
}