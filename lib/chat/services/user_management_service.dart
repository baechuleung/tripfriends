// lib/services/user_management_service.dart - 프렌즈용
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class UserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // 생성자에서 데이터베이스 URL 설정
  UserManagementService() {
    _database.databaseURL = 'https://tripjoy-d309f-default-rtdb.asia-southeast1.firebasedatabase.app/';
  }

  // 사용자 신고하기
  Future<void> reportUser({
    required String reporterId, // 신고자 ID (프렌즈 ID)
    required String reportedUserId, // 신고 대상 사용자 ID (고객 ID)
    required String reason, // 신고 이유
    String? customReason, // 기타 이유의 경우 상세 설명
  }) async {
    try {
      // 신고 정보 생성
      final reportData = {
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'customReason': customReason,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // 처리 상태 (pending, reviewed, resolved 등)
        'reportType': 'friends_to_customer', // 신고 유형 추가 (프렌즈 -> 고객)
      };

      // Firestore에 신고 정보 저장
      await _firestore.collection('reports').add(reportData);

      print('사용자 신고 성공: $reportedUserId');
    } catch (e) {
      print('사용자 신고 오류: $e');
      throw e;
    }
  }

  // 사용자 차단하기
  Future<void> blockUser({
    required String blockerId, // 차단자 ID (프렌즈 ID)
    required String blockedUserId, // 차단 대상 사용자 ID (고객 ID)
    required String chatId, // 채팅방 ID
  }) async {
    try {
      // 1. 프렌즈의 차단 목록에 추가 (프렌즈는 tripfriends_users 컬렉션에 있음)
      await _firestore.collection('tripfriends_users').doc(blockerId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId])
      });

      // 2. 채팅방 정보 업데이트 - 차단 상태로 변경
      await _database.ref().child('chat/$chatId/info').update({
        'blocked': true,
        'blockedBy': blockerId,
        'blockedAt': ServerValue.timestamp,
        'blockType': 'friends_to_customer', // 차단 유형 추가 (프렌즈 -> 고객)
      });

      // 3. 프렌즈 채팅 목록에서 채팅방 상태 업데이트 (Realtime Database)
      await _database.ref().child('users/$blockerId/chats/$chatId').update({
        'blocked': true,
      });

      // 4. 고객 채팅 목록에서 채팅방 상태 업데이트 (Realtime Database)
      await _database.ref().child('users/$blockedUserId/chats/$chatId').update({
        'blocked': true,
        'blockedByFriends': true, // 프렌즈에 의해 차단됨을 명시
      });

      print('사용자 차단 성공: $blockedUserId');
    } catch (e) {
      print('사용자 차단 오류: $e');
      throw e;
    }
  }

  // 차단된 사용자인지 확인
  Future<bool> isUserBlocked(String userId, String otherUserId) async {
    try {
      // 프렌즈는 tripfriends_users 컬렉션에 있음
      final userDoc = await _firestore.collection('tripfriends_users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        final List<dynamic> blockedUsers = userData['blockedUsers'] ?? [];
        return blockedUsers.contains(otherUserId);
      }
      return false;
    } catch (e) {
      print('차단 사용자 확인 오류: $e');
      return false;
    }
  }

  // 채팅 ID 생성 - 고정된 순서: customerId(고객)_friendsId(프렌즈)
  String getChatId(String friendsId, String customerId) {
    // 프렌즈 앱에서는 매개변수 순서가 다르므로 올바른 순서로 재배치
    return '${customerId}_${friendsId}';
  }

  // 사용자 차단 해제하기
  Future<void> unblockUser(String friendsId, String customerId) async {
    try {
      // 1. 차단 목록에서 제거 (tripfriends_users 컬렉션에서)
      await _firestore.collection('tripfriends_users').doc(friendsId).update({
        'blockedUsers': FieldValue.arrayRemove([customerId])
      });

      // 2. 해당 고객과의 채팅방 ID 찾기
      final chatId = getChatId(friendsId, customerId);

      // 3. 채팅방 차단 관련 필드 삭제
      final chatInfoRef = _database.ref().child('chat/$chatId/info');
      await chatInfoRef.update({
        'blocked': null,
        'blockedBy': null,
        'blockedAt': null,
        'blockType': null,
        'unblockedAt': ServerValue.timestamp, // 해제 시간만 기록
      });

      // 4. 프렌즈 채팅 목록에서 차단 관련 필드 삭제
      await _database.ref().child('users/$friendsId/chats/$chatId').update({
        'blocked': null,
      });

      // 5. 고객 채팅 목록에서 차단 관련 필드 삭제
      await _database.ref().child('users/$customerId/chats/$chatId').update({
        'blocked': null,
        'blockedByFriends': null,
      });

      print('고객 차단 해제 성공: $customerId');
    } catch (e) {
      print('고객 차단 해제 오류: $e');
      throw e;
    }
  }
}