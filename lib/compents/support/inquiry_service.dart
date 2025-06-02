import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/shared_preferences_service.dart';

class InquiryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 컬렉션 상수
  static const String _inquiriesCollection = 'inquiries';
  static const String _inquiryRepliesCollection = 'inquiry_replies';
  static const String _usersCollection = 'tripfriends_users';

  // 현재 사용자의 tripfriendsId 가져오기
  static Future<String?> getCurrentTripFriendsId() async {
    try {
      // SharedPreferences에서 먼저 확인
      String? tripfriendsId = SharedPreferencesService.getUserId();
      if (tripfriendsId != null) {
        return tripfriendsId;
      }

      // Firebase Auth에서 uid 가져오기
      final User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      // 여기서 추가 로직을 통해 tripfriends_users 컬렉션에서 현재 사용자의 문서 ID를 찾을 수 있음
      final QuerySnapshot userSnapshot = await _firestore
          .collection(_usersCollection)
          .where('authUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final tripfriendsId = userSnapshot.docs.first.id;
        // 찾은 ID를 SharedPreferences에 저장해 다음 호출 시 쿼리를 줄임
        // phoneNumber 파라미터 제거
        SharedPreferencesService.saveUserSession(tripfriendsId);
        return tripfriendsId;
      }

      return null;
    } catch (e) {
      print('사용자 ID 조회 오류: $e');
      return null;
    }
  }

  // 1:1 문의 목록 가져오기
  static Future<List<Map<String, dynamic>>> getInquiries() async {
    try {
      final String? tripfriendsId = await getCurrentTripFriendsId();

      if (tripfriendsId == null) {
        return [];
      }

      final QuerySnapshot querySnapshot = await _firestore
          .collection(_inquiriesCollection)
          .where('tripfriendsId', isEqualTo: tripfriendsId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      })
          .toList();
    } catch (e) {
      print('1:1 문의 목록 조회 오류: $e');
      return [];
    }
  }

  // 1:1 문의 등록
  static Future<bool> createInquiry({
    required String category,
    required String title,
    required String content,
  }) async {
    try {
      final String? tripfriendsId = await getCurrentTripFriendsId();

      if (tripfriendsId == null) {
        return false;
      }

      await _firestore.collection(_inquiriesCollection).add({
        'tripfriendsId': tripfriendsId,
        'category': category,
        'title': title,
        'content': content,
        'date': FieldValue.serverTimestamp(),
        'status': '답변 대기중',
      });

      return true;
    } catch (e) {
      print('1:1 문의 등록 오류: $e');
      return false;
    }
  }

  // 1:1 문의 상세 조회
  static Future<Map<String, dynamic>?> getInquiryDetail(String inquiryId) async {
    try {
      final DocumentSnapshot docSnapshot =
      await _firestore.collection(_inquiriesCollection).doc(inquiryId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // 답변 조회
        final QuerySnapshot replySnapshot = await _firestore
            .collection(_inquiryRepliesCollection)
            .where('inquiryId', isEqualTo: inquiryId)
            .get();

        Map<String, dynamic>? replyData;
        if (replySnapshot.docs.isNotEmpty) {
          final replyDoc = replySnapshot.docs.first;
          replyData = {
            'id': replyDoc.id,
            ...(replyDoc.data() as Map<String, dynamic>),
          };
        }

        return {
          'id': docSnapshot.id,
          ...data,
          'reply': replyData,
        };
      }

      return null;
    } catch (e) {
      print('1:1 문의 상세 조회 오류: $e');
      return null;
    }
  }
}