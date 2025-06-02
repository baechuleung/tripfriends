// lib/services/fcm_service/handlers/chat_handler.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripfriends/chat/screens/friend_chat_screen.dart';  // 절대 경로로 변경
import 'message_handler.dart';  // navigatorKey 접근용

class ChatHandler {
  // 대기 중인 채팅 메시지를 저장할 정적 변수
  static Map<String, dynamic>? _pendingChatData;

  // 현재 활성화된 채팅방 정보를 저장할 정적 변수들
  static String? _currentUserId;
  static String? _currentCustomerId;
  static String? _currentChatId;
  static bool _isInChatScreen = false;

  // Getter 메서드들 추가 (외부에서 접근 가능)
  static bool get isInChatScreen => _isInChatScreen;
  static String? get currentChatId => _currentChatId;
  static String? get currentUserId => _currentUserId;
  static String? get currentCustomerId => _currentCustomerId;

  // 현재 채팅방 상태 업데이트 (ChatScreen에서 호출하도록 함)
  static void setCurrentChatRoom(String userId, String customerId, {String? chatId}) {
    _currentUserId = userId;
    _currentCustomerId = customerId;

    // chatId가 제공되면 사용, 아니면 userId와 customerId를 조합하여 생성
    if (chatId != null) {
      _currentChatId = chatId;
    } else {
      // userId와 customerId를 정렬하여 일관된 chatId 형태를 생성
      List<String> ids = [userId, customerId];
      ids.sort();
      _currentChatId = '${ids[0]}_${ids[1]}';
    }

    _isInChatScreen = true;
    print('💬 [채팅] 현재 채팅방 설정: userId=$userId, customerId=$customerId, chatId=$_currentChatId');

    // Firestore에 현재 활성 채팅방 정보 저장 (서버에서 확인 가능하도록)
    if (_currentChatId != null) {
      _updateActiveChatRoom(userId, _currentChatId!);
    }
  }

  // 채팅방에서 나갈 때 호출
  static void clearCurrentChatRoom() {
    if (_currentUserId != null) {
      // Firestore에서 활성 채팅방 정보 제거
      _clearActiveChatRoom(_currentUserId!);
    }

    _isInChatScreen = false;
    _currentUserId = null;
    _currentCustomerId = null;
    _currentChatId = null;
    print('💬 [채팅] 채팅방 나감: 상태 초기화');
  }

  // Firestore에 현재 활성 채팅방 정보 업데이트
  static Future<void> _updateActiveChatRoom(String userId, String chatId) async {
    try {
      // 트립프렌즈는 tripfriends_users 컬렉션 사용
      await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(userId)
          .update({
        'activeChatId': chatId,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore에 활성 채팅방 정보 저장: $chatId');
    } catch (e) {
      print('⚠️ 활성 채팅방 정보 저장 실패: $e');

      // 문서가 없을 경우 생성 시도
      try {
        await FirebaseFirestore.instance
            .collection('tripfriends_users')
            .doc(userId)
            .set({
          'activeChatId': chatId,
          'lastActiveAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ Firestore에 활성 채팅방 정보 새로 생성');
      } catch (e2) {
        print('⚠️ 활성 채팅방 정보 생성도 실패: $e2');
      }
    }
  }

  // Firestore에서 활성 채팅방 정보 제거
  static Future<void> _clearActiveChatRoom(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(userId)
          .update({
        'activeChatId': FieldValue.delete(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore에서 활성 채팅방 정보 제거');
    } catch (e) {
      print('⚠️ 활성 채팅방 정보 제거 실패: $e');
    }
  }

  // 앱이 시작될 때 호출되는 초기화 메서드
  static void initialize() {
    // 이전에 저장된 채팅 데이터가 있으면 처리
    if (_pendingChatData != null) {
      print('🔄 앱 초기화 완료: 대기 중인 채팅 메시지 처리 시도');
      handleChatMessage(_pendingChatData!);
      _pendingChatData = null;
    }
  }

  static void handleChatMessage(Map<String, dynamic> data) {
    // 채팅 관련 데이터 추출
    String? chatId = data['chat_id'];
    String? senderId = data['sender_id'];
    String? receiverId = data['receiver_id'];
    String? senderName = data['title'] ?? '프렌즈';
    String? message = data['message'] ?? data['body'] ?? '';

    print('💬 채팅 메시지 알림 처리: chatId=$chatId, senderId=$senderId, receiverId=$receiverId');

    if (chatId != null && senderId != null && receiverId != null) {
      // 현재 가능한 상태인지 확인 (내비게이터 상태 체크)
      if (navigatorKey.currentState == null) {
        print('⚠️ 내비게이터 상태가 없습니다. 채팅 데이터 저장');
        // 데이터 저장 후 나중에 처리
        _pendingChatData = Map<String, dynamic>.from(data);
        return;
      }

      // 현재 사용자 ID 가져오기 (senderId, receiverId 중 하나가 현재 사용자)
      // 여기서는 receiverId가 현재 사용자라고 가정 (수신자가 현재 사용자)
      final currentUserId = receiverId;
      final otherUserId = senderId;

      // 채팅 화면으로 이동 (기존 스택 정리 후)
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            friendsId: currentUserId,
            customerId: otherUserId,
            customerName: senderName ?? '프렌즈',  // null 체크 처리
            customerImage: null,  // 이미지는 화면에서 로드
          ),
        ),
            (route) => route.isFirst,  // 첫 번째 라우트(홈 화면)만 남김
      );

      print('💬 채팅 화면으로 이동 완료: 상대방=$otherUserId');
    } else {
      print('⚠️ 채팅 메시지 처리에 필요한 정보가 부족합니다.');
    }
  }

  static void processChatMessage(Map<String, dynamic> data) {
    print('💬 채팅 메시지 처리 중: ${data['chat_id']}');
  }
}