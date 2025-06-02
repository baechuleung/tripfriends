// features/profile/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/shared_preferences_service.dart';
import '../../../main_page.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static String? _currentStreamUserId;
  static Stream<DocumentSnapshot>? _cachedStream;

  // 포인트 데이터 가져오기
  static Future<int> getUserPoint(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('tripfriends_users').doc(userId).get();
      final data = docSnapshot.data();
      if (data != null && data.containsKey('point')) {
        return data['point'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('포인트 가져오기 오류: $e');
      return 0;
    }
  }

  // 특정 사용자의 리뷰 수를 가져오는 메소드
  static Future<int> getUserReviewCount(String userId) async {
    try {
      // tripfriends_users 문서 내의 중첩된 reviews 컬렉션의 문서 수를 가져옴
      final querySnapshot = await _firestore
          .collection('tripfriends_users')
          .doc(userId)
          .collection('reviews')
          .get();

      return querySnapshot.size; // 문서 수 반환
    } catch (e) {
      print('리뷰 수 가져오기 오류: $e');
      return 0;
    }
  }

  static Future<void> signOut(BuildContext context) async {
    try {
      print('로그아웃 시도');
      // 먼저 Firebase에서 로그아웃 (이 순서가 중요)
      await _auth.signOut();
      // 그 다음 모든 로컬 데이터 정리
      await SharedPreferencesService.clearUserSession();
      _clearCachedStream(); // 스트림 캐시 정리
      print('✅ 로그아웃 완료');

      // 메인 페이지로 강제 이동
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainPage()),
              (route) => false,
        );
      }
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  static Stream<DocumentSnapshot> tripfriendsStream(String? userId) {
    if (userId == null) {
      throw Exception('유저 ID가 없습니다');
    }

    // 동일한 userId에 대한 스트림이 이미 존재하면 캐시된 스트림을 반환
    if (_currentStreamUserId == userId && _cachedStream != null) {
      return _cachedStream!;
    }

    print('트립메이트 데이터 스트림 시작 - UID: $userId');
    _currentStreamUserId = userId;
    _cachedStream = _firestore.collection('tripfriends_users').doc(userId).snapshots();
    return _cachedStream!;
  }

  static void _clearCachedStream() {
    _currentStreamUserId = null;
    _cachedStream = null;
  }
}