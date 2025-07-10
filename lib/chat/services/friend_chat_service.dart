// lib/chat/services/friend_chat_service.dart - 트립프렌즈 앱(프렌즈용)
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_chat_message.dart';

class ChatService {
  final FirebaseDatabase _database;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 프로필 정보 캐시 추가
  static final Map<String, Map<String, dynamic>> _profileCache = {};

  // 현재 활성화된 채팅방 ID 관리 (싱글톤 패턴 사용)
  static String? _activeChatId;

  // 현재 활성화된 채팅방 setter (Firebase Firestore에도 저장하도록 수정)
  static Future<void> setActiveChatId(String? chatId) async {
    _activeChatId = chatId;
    print('현재 활성화된 채팅방 ID 설정: $_activeChatId');

    // Firestore에도 활성화된 채팅방 정보 저장
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;

        // user_active_chats 컬렉션에 저장
        await FirebaseFirestore.instance
            .collection('user_active_chats')
            .doc(userId)
            .set({
          'chat_id': chatId,
          'user_id': userId,
          'updated_at': FieldValue.serverTimestamp(),
          'app_state': 'foreground'  // 앱 상태 추가
        }, SetOptions(merge: true));

        print('Firestore에 활성 채팅방 정보 저장 완료: $chatId');
      }
    } catch (e) {
      print('활성 채팅방 정보 저장 중 오류 발생: $e');
    }
  }

  // 앱 상태 설정 메서드 추가 (백그라운드 상태 감지용)
  static Future<void> setAppState(String state) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;

        await FirebaseFirestore.instance
            .collection('user_active_chats')
            .doc(userId)
            .set({
          'app_state': state,
          'updated_at': FieldValue.serverTimestamp(),
          'user_id': userId
        }, SetOptions(merge: true));

        print('앱 상태 업데이트: $state');

        // 앱이 백그라운드로 갔을 때 활성 채팅방 ID 초기화
        if (state == 'background') {
          _activeChatId = null;

          await FirebaseFirestore.instance
              .collection('user_active_chats')
              .doc(userId)
              .update({'chat_id': null});

          print('앱이 백그라운드로 전환되어 활성 채팅방 ID 초기화됨');
        }
      }
    } catch (e) {
      print('앱 상태 업데이트 중 오류 발생: $e');
    }
  }

  // 현재 활성화된 채팅방 getter
  static String? get activeChatId => _activeChatId;

  ChatService() : _database = FirebaseDatabase.instance {
    // Firebase Realtime Database URL 설정
    _database.databaseURL = 'https://tripjoy-d309f-default-rtdb.asia-southeast1.firebasedatabase.app/';
  }

  // 고객 정보 가져오기 (캐싱 적용)
  Future<Map<String, dynamic>> getCustomerInfo(String userId) async {
    try {
      // 캐시에 이미 있는지 확인
      if (_profileCache.containsKey(userId)) {
        print('캐시에서 고객 정보 로드: $userId');
        return _profileCache[userId]!;
      }

      // 캐시에 없으면 Firestore에서 조회
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        final photoUrl = userData['photoUrl'];

        // 결과 생성
        final profileInfo = {
          'name': userData['name'] ?? '고객',
          'profileImageUrl': photoUrl,
        };

        // 결과를 캐시에 저장
        _profileCache[userId] = profileInfo;
        print('Firestore에서 고객 정보 로드 및 캐시에 저장: $userId');

        return profileInfo;
      }

      // 고객 정보가 없는 경우 기본값 캐싱
      final defaultInfo = {
        'name': '고객',
        'profileImageUrl': null
      };
      _profileCache[userId] = defaultInfo;

      return defaultInfo;
    } catch (e) {
      print('고객 정보 가져오기 오류: $e');
      return {
        'name': '고객',
        'profileImageUrl': null
      };
    }
  }

  // 캐시 삭제 메서드 (필요 시 호출)
  static void clearProfileCache() {
    _profileCache.clear();
    print('프로필 캐시가 초기화되었습니다.');
  }

  // 특정 사용자 캐시 삭제 메서드
  static void removeFromCache(String userId) {
    _profileCache.remove(userId);
    print('프로필 캐시에서 제거됨: $userId');
  }

  // 채팅 ID 생성 - 고정된 순서: customerId(고객)_friendsId(프렌즈)
  String getChatId(String friendsId, String customerId) {
    // 프렌즈 앱에서는 매개변수 순서가 friendsId, customerId이므로
    // 올바른 순서로 재배치: customerId_friendsId
    return '${customerId}_${friendsId}';
  }

  // 메시지 보내기
  Future<void> sendMessage(String friendsId, String customerId, String content) async {
    final String chatId = getChatId(friendsId, customerId);
    final now = DateTime.now();

    // 디버깅 로그 추가
    print('sendMessage 호출됨 - 보내는 사람ID: $friendsId, 받는 사람ID: $customerId, 내용: $content');

    // 프렌즈가 보내는 사람, 고객이 받는 사람
    final message = ChatMessage(
      senderId: friendsId,
      receiverId: customerId,
      content: content,
      timestamp: now,
      isRead: false, // 초기값은 읽지 않음 상태
    );

    try {
      // 메시지 추가
      final messageRef = _database.ref().child('chat/$chatId/messages').push();
      await messageRef.set(message.toMap());

      // 저장된 데이터 확인을 위한 디버깅 로그
      print('메시지 저장됨 - 보낸이: ${message.senderId}, 받는이: ${message.receiverId}');

      // 채팅 정보 업데이트
      await _database.ref().child('chat/$chatId/info').update({
        'latestMessage': content,
        'timestamp': now.millisecondsSinceEpoch,
        'lastSenderId': friendsId,
        'participants': [friendsId, customerId],
        'unreadCount': ServerValue.increment(1),
      });

      // 프렌즈의 채팅 목록 업데이트
      await _database.ref().child('users/$friendsId/chats/$chatId').update({
        'otherUserId': customerId,
        'latestMessage': content,
        'timestamp': now.millisecondsSinceEpoch,
        'unreadCount': 0,  // 프렌즈는 자신의 메시지를 읽은 상태
      });

      // 고객의 채팅 목록 업데이트
      await _database.ref().child('users/$customerId/chats/$chatId').update({
        'otherUserId': friendsId,
        'latestMessage': content,
        'timestamp': now.millisecondsSinceEpoch,
        'unreadCount': ServerValue.increment(1),  // 고객의 읽지 않은 메시지 수 증가
      });

      // Realtime Database 업데이트만으로 충분함
      // Firebase Functions 트리거가 자동으로 작동하여 필요한 경우 푸시 알림을 전송함
      print('메시지 전송 완료 - 트리거 함수가 알림을 처리할 것임');

    } catch (e) {
      print('메시지 전송 오류: $e');
      throw e;
    }
  }

  // 특정 채팅의 메시지 목록 가져오기 - 실시간 업데이트 지원
  Stream<List<ChatMessage>> getMessages(String friendsId, String customerId) {
    final String chatId = getChatId(friendsId, customerId);
    print('프렌즈앱 - 채팅 ID 확인: $chatId, friendsId: $friendsId, customerId: $customerId');

    // 현재 채팅방을 활성 채팅방으로 설정
    setActiveChatId(chatId);

    // 현재 채팅방의 읽지 않은 메시지 수 초기화 (프렌즈 입장에서)
    _database.ref().child('users/$friendsId/chats/$chatId').update({
      'unreadCount': 0,
    });

    return _database
        .ref()
        .child('chat/$chatId/messages')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      print('프렌즈앱 - 데이터 변경 감지: ${event.snapshot.exists}');
      final List<ChatMessage> messages = [];

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        data.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value);
          final isRead = messageData['isRead'] ?? false;

          // 읽음 상태 로그 추가
          final senderId = messageData['senderId'];
          if (senderId == friendsId) {
            print('프렌즈 메시지 읽음 상태 확인: id=$key, isRead=$isRead');
          } else {
            print('고객 메시지 읽음 상태 확인: id=$key, isRead=$isRead');
          }

          // 메시지 객체 생성
          messages.add(ChatMessage.fromMap(messageData));
        });

        // 시간순 정렬
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }

      return messages;
    });
  }

  // 채팅방 나가기 처리 (채팅방 화면 떠날 때 호출)
  Future<void> leaveChat() async {
    try {
      // 활성 채팅방 ID 초기화
      await setActiveChatId(null);
      print('채팅방에서 나감 - 활성 채팅방 ID 초기화됨');
    } catch (e) {
      print('채팅방 나가기 처리 중 오류 발생: $e');
    }
  }
}