import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/translation_service.dart';  // TranslationService import 추가

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final TranslationService _translationService = TranslationService();  // TranslationService 인스턴스 추가

  // 초기화 및 번역 서비스 로드
  static Future<void> init() async {
    await _translationService.init();
  }

  // 컬렉션 상수
  static const String _announcementsCollection = 'announcements';
  // _userNotificationStatusCollection 변수 제거함

  // 공지사항 목록 가져오기
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_announcementsCollection)
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
      print('${_translationService.get('notification_list_error', '공지사항 목록 조회 오류')}: $e');
      return [];
    }
  }

  // 공지사항 상세 조회
  static Future<Map<String, dynamic>?> getAnnouncementDetail(String announcementId) async {
    try {
      final DocumentSnapshot docSnapshot =
      await _firestore.collection(_announcementsCollection).doc(announcementId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return {
          'id': docSnapshot.id,
          ...data,
        };
      }

      return null;
    } catch (e) {
      print('${_translationService.get('notification_detail_error', '공지사항 상세 조회 오류')}: $e');
      return null;
    }
  }

  // 읽지 않은 공지사항 수 조회 (user_notification_status 컬렉션 사용 부분 제거)
  static Future<int> getUnreadAnnouncementsCount() async {
    try {
      // 가장 최근 공지사항만 가져오기
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_announcementsCollection)
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('${_translationService.get('unread_notification_error', '읽지 않은 공지사항 수 조회 오류')}: $e');
      return 0;
    }
  }
}