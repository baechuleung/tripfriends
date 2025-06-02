import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/translation_service.dart';

class EmailAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TranslationService _translationService = TranslationService();

  EmailAuthService() {
    _translationService.init();
  }

  // 이메일과 비밀번호로 로그인
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
    try {
      // 소셜 로그인과 유사하게 처리하기 위해 먼저 로그아웃
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print('기존 로그인 세션 로그아웃 완료');
      }

      // 이메일 로그인 (소셜 로그인과 동일한 패턴으로 단순화)
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw _translationService.get('auth_error', '인증에 실패했습니다.');
      }

      // Firestore에서 사용자 정보 확인 (소셜 로그인과 동일)
      final userDoc = await _firestore.collection('tripfriends_users').doc(uid).get();
      final bool isNewUser = !userDoc.exists || !userDoc.data()!.containsKey('name');

      print('📱 이메일 로그인 성공: $uid');

      return {
        'userCredential': userCredential,
        'isNewUser': isNewUser,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw _translationService.get('user_not_found', '해당 이메일로 등록된 사용자가 없습니다.');
      } else if (e.code == 'wrong-password') {
        throw _translationService.get('wrong_password', '잘못된 비밀번호입니다.');
      } else {
        throw _translationService.get('login_error', '로그인 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw _translationService.get('login_error_general', '로그인 중 오류가 발생했습니다: $e');
    }
  }

  // 이메일과 비밀번호로 회원가입
  Future<Map<String, dynamic>?> registerWithEmail(String email, String password) async {
    try {
      // 소셜 로그인과 유사하게 처리하기 위해 먼저 로그아웃
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print('기존 로그인 세션 로그아웃 완료');
      }

      // 이메일 회원가입 (소셜 로그인과 동일한 패턴으로 단순화)
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw _translationService.get('auth_error', '인증에 실패했습니다.');
      }

      print('📱 이메일 회원가입 성공: $uid');

      return {
        'userCredential': userCredential,
        'isNewUser': true,
      };
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw _translationService.get('weak_password', '비밀번호가 너무 약합니다.');
      } else if (e.code == 'email-already-in-use') {
        throw _translationService.get('email_in_use', '이미 사용 중인 이메일입니다.');
      } else {
        throw _translationService.get('register_error', '회원가입 중 오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      throw _translationService.get('register_error_general', '회원가입 중 오류가 발생했습니다: $e');
    }
  }

  // 비밀번호 재설정 이메일 보내기
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _translationService.get('reset_email_error', '비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: ${e.message}');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}