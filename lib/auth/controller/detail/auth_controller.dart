import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/shared_preferences_service.dart';

class AuthController {
  // Firebase 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 인증된 사용자 가져오기
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 세션 저장 및 토큰 갱신 - phoneNumber 파라미터 제거
  Future<void> saveSessionAndRefreshToken(String userId) async {
    print('💾 세션 정보 저장 시도');

    // 현재 사용자가 있는지 확인
    final currentUser = _auth.currentUser;

    // 현재 사용자가 없거나 UID가 일치하지 않으면 강제로 사용자 데이터 설정
    if (currentUser == null || currentUser.uid != userId) {
      print('⚠️ 현재 인증된 사용자 없음 또는 UID 불일치 - 강제 저장 진행');
    }

    // SharedPreferences에 사용자 세션 저장 (phoneNumber 없이 저장)
    final sessionSaved = await SharedPreferencesService.saveUserSession(userId);

    if (!sessionSaved) {
      print('⚠️ 세션 저장 실패 - 무시하고 계속 진행');
    } else {
      print('✅ 세션 저장 완료');
    }

    // 현재 사용자가 있는 경우에만 토큰 갱신 시도
    if (currentUser != null) {
      try {
        await currentUser.getIdToken(true);
        print('✅ 토큰 갱신 완료');
      } catch (e) {
        print('⚠️ 토큰 갱신 실패 - 무시하고 계속 진행: $e');
      }
    }
  }

  // 로그아웃 처리
  Future<void> signOut() async {
    await _auth.signOut();
    await SharedPreferencesService.clearUserSession();
    print('✅ 로그아웃 완료');
  }

  // 인증 상태 변경 리스너
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}