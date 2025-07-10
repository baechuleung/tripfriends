// lib/chat/services/friend_message_reader.dart - 트립프렌즈 앱(프렌즈용)
import 'package:firebase_database/firebase_database.dart';

class MessageReaderService {
  final FirebaseDatabase _database;

  MessageReaderService() : _database = FirebaseDatabase.instance;

  // 채팅 ID 생성 - 고정된 순서: customerId(고객)_friendsId(프렌즈)
  String getChatId(String friendsId, String customerId) {
    // 프렌즈 앱에서는 매개변수 순서가 다르므로 올바른 순서로 재배치
    return '${customerId}_${friendsId}';
  }

  // 메시지를 읽음 상태로 표시 - 개선된 버전
  Future<void> markMessagesAsRead(String friendsId, String customerId) async {
    final String chatId = getChatId(friendsId, customerId);
    print('프렌즈앱 - 메시지 읽음 표시 시작: friendsId=$friendsId, customerId=$customerId');

    try {
      // 1. 프렌즈의 채팅 목록에서 읽지 않은 메시지 카운트 리셋
      await _database.ref().child('users/$friendsId/chats/$chatId').update({
        'unreadCount': 0,
      });
      print('프렌즈앱 - 채팅 목록 unreadCount 리셋 완료');

      // 2. 메시지 읽음 상태 업데이트 - 고객이 보낸 메시지만 읽음 표시
      final messagesSnapshot = await _database
          .ref()
          .child('chat/$chatId/messages')
          .orderByChild('senderId')
          .equalTo(customerId)  // 고객이 보낸 메시지만 필터링
          .get();

      int updatedCount = 0;
      if (messagesSnapshot.exists && messagesSnapshot.value != null) {
        final messages = Map<String, dynamic>.from(messagesSnapshot.value as Map);
        print('고객이 보낸 메시지 ${messages.length}개 읽음 표시 시작');

        // 업데이트할 메시지 목록 생성
        List<Future> updatePromises = [];

        // 각 메시지 읽음 상태로 업데이트
        for (var entry in messages.entries) {
          final key = entry.key;
          final message = Map<String, dynamic>.from(entry.value);

          // isRead가 false일 경우 true로 업데이트
          if (!(message['isRead'] as bool? ?? false)) {
            updatePromises.add(
                _database.ref().child('chat/$chatId/messages/$key').update({
                  'isRead': true
                })
            );
            updatedCount++;
          }
        }

        // 모든 업데이트 일괄 처리
        if (updatePromises.isNotEmpty) {
          await Future.wait(updatePromises);
        }
      }
      print('총 $updatedCount개 메시지 읽음 표시 완료');

      // 3. 채팅 정보의 읽지 않은 메시지 카운트 리셋
      await _database.ref().child('chat/$chatId/info').update({
        'unreadCount': 0,
      });
      print('채팅 정보 unreadCount 리셋 완료');
    } catch (e) {
      print('메시지 읽음 표시 과정 중 오류 발생: $e');
    }
  }

  // 빠른 읽음 표시 함수 - 화면 터치 시 호출
  Future<void> quickMarkAsRead(String friendsId, String customerId) async {
    final String chatId = getChatId(friendsId, customerId);

    try {
      // 고객이 보낸 메시지만 읽음 표시 업데이트
      final messagesSnapshot = await _database
          .ref()
          .child('chat/$chatId/messages')
          .orderByChild('senderId')
          .equalTo(customerId)
          .get();

      if (messagesSnapshot.exists && messagesSnapshot.value != null) {
        final messages = Map<String, dynamic>.from(messagesSnapshot.value as Map);

        // 읽지 않은 메시지만 업데이트
        List<Future> updatePromises = [];
        for (var entry in messages.entries) {
          final key = entry.key;
          final message = Map<String, dynamic>.from(entry.value);

          if (!(message['isRead'] as bool? ?? false)) {
            updatePromises.add(
                _database.ref().child('chat/$chatId/messages/$key').update({
                  'isRead': true
                })
            );
          }
        }

        // 모든 업데이트 일괄 처리
        if (updatePromises.isNotEmpty) {
          await Future.wait(updatePromises);

          // 읽음 표시 추가 처리
          await _database.ref().child('chat/$chatId/info').update({
            'unreadCount': 0,
          });

          await _database.ref().child('users/$friendsId/chats/$chatId').update({
            'unreadCount': 0,
          });

          print('퀵 업데이트: ${updatePromises.length}개 메시지 읽음 표시 완료');
        }
      }
    } catch (e) {
      print('빠른 읽음 표시 오류: $e');
    }
  }

  // 메시지 읽음 상태 업데이트 확인 메서드
  Future<void> checkForReadStatusUpdates(String senderId, String receiverId) async {
    final String chatId = getChatId(senderId, receiverId);

    try {
      // 프렌즈가 보낸 메시지만 필터링
      final messagesSnapshot = await _database
          .ref()
          .child('chat/$chatId/messages')
          .orderByChild('senderId')
          .equalTo(senderId)
          .get();

      if (messagesSnapshot.exists && messagesSnapshot.value != null) {
        final messages = Map<String, dynamic>.from(messagesSnapshot.value as Map);

        // 메시지 읽음 상태 확인 및 디버깅 출력
        int totalMessages = 0;
        int readMessages = 0;

        messages.forEach((key, value) {
          final message = Map<String, dynamic>.from(value);
          totalMessages++;
          if (message['isRead'] == true) {
            readMessages++;
          }
        });

        print('프렌즈가 보낸 메시지 읽음 상태 확인: 총 $totalMessages개 중 $readMessages개 읽음');
      } else {
        print('프렌즈가 보낸 메시지가 없습니다.');
      }
    } catch (e) {
      print('읽음 상태 업데이트 확인 중 오류 발생: $e');
      throw e;
    }
  }
}