import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // 페이스북 로그인 상태 확인
      final accessToken = await FacebookAuth.instance.accessToken;
      if (accessToken != null) {
        // 이미 로그인된 상태면 로그아웃
        await FacebookAuth.instance.logOut();
        print('기존 페이스북 세션 로그아웃 완료');
      }

      // 페이스북 로그인 실행
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      print('페이스북 로그인 상태: ${result.status}');
      print('페이스북 로그인 메시지: ${result.message}');

      // 로그인 상태 확인
      if (result.status != LoginStatus.success) {
        print('페이스북 로그인 실패: ${result.status}');
        return null;
      }

      // Facebook 액세스 토큰 획득
      final AccessToken? resultAccessToken = result.accessToken;
      if (resultAccessToken == null) {
        print('페이스북 액세스 토큰이 null입니다');
        return null;
      }

      print('페이스북 토큰 획득 성공: ${resultAccessToken.tokenString.substring(0, 10)}...');

      // Facebook 인증 정보로 Firebase 인증
      final OAuthCredential credential = FacebookAuthProvider.credential(
        resultAccessToken.tokenString,
      );

      // Firebase 인증 완료
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('Firebase 인증 성공: ${userCredential.user?.uid}');

      final uid = userCredential.user?.uid;
      if (uid == null) {
        print('Firebase 사용자 ID가 null입니다');
        return null;
      }

      // Firestore에서 사용자 가입 여부 확인
      final userDoc = await FirebaseFirestore.instance.collection('tripfriends_users').doc(uid).get();
      final isNewUser = !userDoc.exists;
      print('신규 사용자 여부: $isNewUser');

      return {
        'userCredential': userCredential,
        'isNewUser': isNewUser,
      };
    } catch (e) {
      print('페이스북 로그인 중 예외 발생: $e');
      // 예외 스택 트레이스 출력
      print(StackTrace.current);
      return null;
    }
  }
}