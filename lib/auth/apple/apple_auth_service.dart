import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      // 기존 Firebase 세션 로그아웃 처리
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final uid = userCredential.user?.uid;
      if (uid == null) return null;

      final userDoc = await FirebaseFirestore.instance.collection('tripfriends_users').doc(uid).get();
      final isNewUser = !userDoc.exists;

      return {
        'userCredential': userCredential,
        'isNewUser': isNewUser,
      };
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // 사용자가 로그인을 취소한 경우, null을 반환하고 오류를 표시하지 않음
        return null;
      }
      // 다른 예외는 다시 던짐
      rethrow;
    } catch (e) {
      // 그 외 예외 처리
      print('Apple 로그인 중 오류 발생: $e');
      return null;
    }
  }
}