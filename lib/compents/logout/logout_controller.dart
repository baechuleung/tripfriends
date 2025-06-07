import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/shared_preferences_service.dart';
import '../../main_page.dart'; // MainPage로 변경

class LogoutController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    try {
      // 먼저 SharedPreferences에서 세션 초기화
      await SharedPreferencesService.clearUserSession();
      debugPrint('🧹 로그아웃: 세션 데이터 초기화 완료');

      // Firebase 로그아웃
      await _auth.signOut();
      debugPrint('🔐 로그아웃 성공');

      if (context.mounted) {
        // 로그아웃 후 MainPage로 이동 (auth_main_page.dart 대신)
        debugPrint('🧭 로그아웃 후 메인 페이지로 이동');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ 로그아웃 중 오류 발생: $e');
    }
  }
}