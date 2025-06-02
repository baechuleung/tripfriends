// lib/services/fcm_service/token/token_manager.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared_preferences_service.dart';

class TokenManager {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 저장된 토큰 확인 (수정됨)
  static Future<void> checkExistingToken() async {
    // 현재 로그인된 사용자 확인
    User? currentUser = _auth.currentUser;

    // 로그인된 사용자가 없으면 토큰 정리
    if (currentUser == null) {
      print('👤 로그인된 사용자 없음, FCM 토큰 삭제');
      await SharedPreferencesService.removeFCMToken();
      return;
    }

    String? savedToken = await SharedPreferencesService.getFCMToken();
    String? savedUid = SharedPreferencesService.getUserUid();

    print('🔍 저장된 FCM 토큰 확인: ${savedToken != null ? "${savedToken.substring(0, 10)}..." : "없음"}');
    print('🔍 저장된 UID 확인: $savedUid, 현재 UID: ${currentUser.uid}');

    // 로그인 사용자가 변경되었거나 토큰이 없는 경우
    if (savedUid != currentUser.uid || savedToken == null || savedToken.isEmpty) {
      print('👤 사용자 변경 또는 토큰 없음, 새 토큰 요청');
      await getToken();
      return;
    }

    // 현재 로그인된 사용자와 저장된 UID가 일치하면 토큰 업데이트
    if (currentUser.uid == savedUid) {
      await updateTokenInDatabase(currentUser.uid, savedToken);
    }
  }

  // FCM 토큰 발급 및 가져오기 (수정됨)
  static Future<String?> getToken() async {
    try {
      print('🔔 FCM 토큰 요청 시작');

      // 현재 사용자 확인
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('⚠️ 로그인된 사용자 없음, 토큰 요청 취소');
        return null;
      }

      // FCM 권한 요청
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('🔔 FCM 알림 권한 획득: ${settings.authorizationStatus}');

        // 토큰 얻기
        String? token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          print('🔑 FCM 토큰 발급 성공: ${token.substring(0, 10)}...'); // 보안을 위해 토큰 일부만 로그

          // 토큰 저장
          await SharedPreferencesService.setFCMToken(token);

          // Firestore에서 이 기기의 이전 토큰들 모두 제거
          await cleanupOldTokens(token);

          // 현재 사용자의 정보로 토큰 저장
          await updateTokenInDatabase(currentUser.uid, token);

          return token;
        } else {
          print('⚠️ FCM 토큰이 비어있음');
          return null;
        }
      } else {
        print('❌ FCM 알림 권한 거부됨');
        return null;
      }
    } catch (e) {
      print('❌ FCM 토큰 발급 실패: $e');
      return null;
    }
  }

  // 이전 토큰 정리 메서드 (새로 추가)
  static Future<void> cleanupOldTokens(String currentToken) async {
    try {
      print('🧹 이전 FCM 토큰 정리 시작');

      // 현재 토큰과 동일한 토큰을 가진 모든 사용자 찾기
      QuerySnapshot sameTokenUsers = await _firestore
          .collection('tripfriends_users')
          .where('fcmToken', isEqualTo: currentToken)
          .get();

      // 현재 사용자 정보
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // 현재 사용자가 아닌 다른 사용자들의 토큰 제거
      for (DocumentSnapshot doc in sameTokenUsers.docs) {
        if (doc.id != currentUser.uid) {
          await _firestore
              .collection('tripfriends_users')
              .doc(doc.id)
              .update({'fcmToken': null});

          print('🗑️ 사용자 ${doc.id}의 중복 토큰 제거됨');
        }
      }

      print('✅ 이전 FCM 토큰 정리 완료');
    } catch (e) {
      print('⚠️ 이전 토큰 정리 중 오류: $e');
    }
  }

  // 토큰 갱신 시 콜백 설정
  static void setupTokenRefresh(Function(String) onTokenRefresh) {
    _messaging.onTokenRefresh.listen((String token) {
      print('🔄 FCM 토큰 갱신됨: ${token.substring(0, 10)}...');

      // 갱신된 토큰 저장
      SharedPreferencesService.setFCMToken(token);

      // 현재 로그인된 사용자가 있으면 DB 업데이트
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        cleanupOldTokens(token).then((_) {
          updateTokenInDatabase(currentUser.uid, token);
        });
      }

      onTokenRefresh(token);
    });
  }

  // FCM 토큰 데이터베이스에 업데이트 (Firestore)
  static Future<void> updateTokenInDatabase(String uid, String token) async {
    try {
      // 현재 사용자 확인
      User? currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != uid) {
        print('⚠️ 토큰 업데이트 취소: 로그인된 사용자 없거나 UID 불일치');
        return;
      }

      // Firestore에 FCM 토큰 업데이트
      await _firestore
          .collection('tripfriends_users')
          .doc(uid)
          .update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore의 FCM 토큰 업데이트 완료: uid=$uid');

      // SharedPreferences에 현재 사용자 UID 저장 (phoneNumber 파라미터 제거)
      await SharedPreferencesService.saveUserSession(uid);

    } catch (e) {
      print('⚠️ Firestore에 FCM 토큰 업데이트 실패: $e');

      // 문서가 없을 경우 새로 생성
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('tripfriends_users')
            .doc(uid)
            .get();

        if (!userDoc.exists) {
          await _firestore
              .collection('tripfriends_users')
              .doc(uid)
              .set({
            'fcmToken': token,
            'tokenUpdatedAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          print('✅ 문서가 없어 새로 생성하여 FCM 토큰 저장 완료: uid=$uid');
        }
      } catch (e) {
        print('⚠️ 문서 생성 중 오류: $e');
      }
    }
  }

  // 로그인 시 토큰 업데이트 (수정됨)
  static Future<void> onUserLogin(String uid) async {
    try {
      print('👤 사용자 로그인: $uid');

      // 현재 로그인된 사용자 확인
      User? currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != uid) {
        print('⚠️ 토큰 업데이트 취소: 로그인된 사용자 없거나 UID 불일치');
        return;
      }

      // 이전 토큰 정리
      await cleanupPreviousUserTokens(uid);

      // 새 토큰 발급
      String? token = await getToken();
      if (token != null) {
        await updateTokenInDatabase(uid, token);
      }

      print('✅ 로그인 시 FCM 토큰 업데이트 완료');
    } catch (e) {
      print('⚠️ 로그인 시 FCM 토큰 업데이트 실패: $e');
    }
  }

  // 이전 사용자의 토큰 정리 (새로 추가)
  static Future<void> cleanupPreviousUserTokens(String currentUid) async {
    try {
      String? savedUid = SharedPreferencesService.getUserUid();

      // 이전에 저장된 UID가 있고, 현재 UID와 다르면 이전 사용자의 토큰 제거
      if (savedUid != null && savedUid != currentUid) {
        print('👤 이전 사용자($savedUid)의 토큰 정리');

        await _firestore
            .collection('tripfriends_users')
            .doc(savedUid)
            .update({
          'fcmToken': null,
          'tokenRemovedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('⚠️ 이전 사용자 토큰 정리 중 오류: $e');
    }
  }

  // 로그아웃 시 토큰 삭제 (수정됨)
  static Future<void> onUserLogout(String uid) async {
    try {
      print('👤 사용자 로그아웃: $uid');

      // Firestore에서 토큰 제거
      await _firestore
          .collection('tripfriends_users')
          .doc(uid)
          .update({
        'fcmToken': null,
        'lastLogout': FieldValue.serverTimestamp(),
        'tokenRemovedAt': FieldValue.serverTimestamp(),
      });

      // SharedPreferences에서 토큰 제거
      await SharedPreferencesService.removeFCMToken();

      // FCM 토큰 무효화 (Firebase에서 제공하는 경우)
      try {
        await _messaging.deleteToken();
        print('🗑️ FCM 토큰 삭제됨');
      } catch (e) {
        print('⚠️ FCM 토큰 삭제 중 오류: $e');
      }

      print('✅ 로그아웃 시 FCM 토큰 삭제 완료');
    } catch (e) {
      print('⚠️ 로그아웃 시 FCM 토큰 삭제 실패: $e');
    }
  }
}