import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActiveController extends ChangeNotifier {
  bool _isActive = false;
  String? _currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isActive => _isActive;

  // 초기화
  Future<void> init() async {
    debugPrint('ActiveController.init() 호출됨');

    try {
      // 현재 로그인된 사용자 ID 가져오기
      _currentUserId = _auth.currentUser?.uid;
      if (_currentUserId == null) {
        debugPrint('현재 로그인된 사용자 없음, 초기화 중단');
        return;
      }

      debugPrint('현재 로그인된 사용자 ID: $_currentUserId');

      // 사용자 문서 조회
      final doc = await _firestore
          .collection('tripfriends_users')
          .doc(_currentUserId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        debugPrint('문서 존재함: $data');

        if (data != null && data.containsKey('isActive')) {
          final value = data['isActive'];
          if (value is bool) {
            _isActive = value;
          } else if (value is int) {
            _isActive = value > 0;
          } else if (value is String) {
            _isActive = value.toLowerCase() == 'true';
          } else {
            _isActive = false;
          }
          debugPrint('isActive 값: $_isActive (타입: ${value.runtimeType})');
        } else {
          debugPrint('isActive 필드 없음, 기본값 false 사용');
        }
      } else {
        debugPrint('사용자 문서 없음: tripfriends_users/$_currentUserId');
      }
    } catch (e) {
      debugPrint('DB 조회 오류: $e');
    }

    notifyListeners();
  }

  // 토글 함수
  Future<void> toggleActive() async {
    if (_currentUserId == null) {
      debugPrint('토글 실패: 로그인된 사용자 ID 없음');
      return;
    }

    debugPrint('토글 시도: 현재=$_isActive, 변경=${!_isActive}, 사용자=$_currentUserId');

    try {
      // 로컬 상태 먼저 변경 (즉시 UI 반영)
      _isActive = !_isActive;
      notifyListeners();

      // 파이어베이스 업데이트
      final docRef = _firestore.collection('tripfriends_users').doc(_currentUserId);

      await docRef.set({
        'isActive': _isActive
      }, SetOptions(merge: true));

      debugPrint('토글 완료: $_isActive (사용자: $_currentUserId)');

      // 업데이트 확인
      final updatedDoc = await docRef.get();
      if (updatedDoc.exists && updatedDoc.data() != null) {
        final updatedValue = updatedDoc.data()!['isActive'];
        debugPrint('업데이트 후 DB 값: $updatedValue (${updatedValue.runtimeType})');
      }
    } catch (e) {
      // 오류 발생 시 상태 원복
      _isActive = !_isActive;
      notifyListeners();
      debugPrint('토글 오류: $e');
    }
  }
}