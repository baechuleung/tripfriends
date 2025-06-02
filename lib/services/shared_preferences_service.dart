// shared_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SharedPreferencesService {
  static const String _languageKey = 'app_language';
  static const String _userIdKey = 'user_id';
  static const String _userPhoneKey = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userUidKey = 'user_uid';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _userDocumentKey = 'user_document';
  static const String _authTokenKey = 'auth_token';
  static const String _tokenTimestampKey = 'token_timestamp'; // 토큰 발급 시간 추가

  static late SharedPreferences _prefs;

  // 알림 설정 키
  static const String _notificationMatchRequestsKey = 'notification_match_requests';
  static const String _notificationMessagesKey = 'notification_messages';
  static const String _notificationPromotionsKey = 'notification_promotions';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await attemptAutoLogin();
  }

  // 자동 로그인 시도 - 개선된 버전
  static Future<bool> attemptAutoLogin() async {
    try {
      // Firebase Auth 상태 확인
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        debugPrint('✅ Firebase Auth에 이미 로그인됨: ${currentUser.uid}');

        // 토큰 갱신이 필요한지 확인
        if (await isTokenRefreshNeeded()) {
          debugPrint('🔄 토큰 갱신 필요');
          await currentUser.getIdToken(true); // 토큰 강제 갱신
          await updateTokenTimestamp();
        }

        return true;
      }

      // 로컬 로그인 상태 확인
      bool isLoggedIn = SharedPreferencesService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('❌ 로그인 상태 아님, 자동 로그인 건너뜀');
        return false;
      }

      String? uid = getUserUid();
      if (uid == null || uid.isEmpty) {
        debugPrint('❌ 저장된 UID 없음, 자동 로그인 실패');
        return false;
      }

      debugPrint('🔄 자동 로그인 시도 - UID: $uid');

      // Firestore에서 사용자 정보 확인
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('❌ Firestore에 사용자 정보 없음, 자동 로그인 실패');
        await clearUserSession();
        return false;
      }

      debugPrint('✅ Firestore에서 사용자 정보 확인됨');

      // 사용자 정보 업데이트
      await saveUserDocument(uid, userDoc.data() as Map<String, dynamic>?);
      await setLoggedIn(true);

      return true;
    } catch (e) {
      debugPrint('❌ 자동 로그인 중 오류: $e');
      return false;
    }
  }

  // 토큰 갱신 필요 여부 확인 (50분 이상 경과 시)
  static Future<bool> isTokenRefreshNeeded() async {
    final timestamp = _prefs.getInt(_tokenTimestampKey);
    if (timestamp == null) return true;

    final lastTokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(lastTokenTime);

    // 50분 이상 경과했으면 갱신 필요
    return difference.inMinutes >= 50;
  }

  // 토큰 타임스탬프 업데이트
  static Future<void> updateTokenTimestamp() async {
    await _prefs.setInt(_tokenTimestampKey, DateTime.now().millisecondsSinceEpoch);
    debugPrint('🕒 토큰 타임스탬프 업데이트됨');
  }

  // 세션 유효성 검사 - 개선된 버전
  static Future<void> validateAndCleanSession() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint('🔍 Firebase Auth 사용자 확인: ${currentUser?.uid ?? "null"}');

      if (currentUser == null) {
        bool isLoggedInLocally = isLoggedIn();

        if (isLoggedInLocally) {
          bool loginSuccess = await attemptAutoLogin();
          if (!loginSuccess) {
            await clearUserSession();
          }
        } else {
          await clearUserSession();
        }
        return;
      }

      // 토큰 갱신 체크
      if (await isTokenRefreshNeeded()) {
        try {
          await currentUser.getIdToken(true);
          await updateTokenTimestamp();
          debugPrint('✅ 토큰 갱신 성공');
        } catch (e) {
          debugPrint('❌ 토큰 갱신 실패: $e');
          // 토큰 갱신 실패 시 재로그인 필요
          await FirebaseAuth.instance.signOut();
          await clearUserSession();
          return;
        }
      }

      // Firestore 사용자 정보 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('❌ Firestore에 사용자 데이터 없음 - 세션 초기화');
        await FirebaseAuth.instance.signOut();
        await clearUserSession();
      } else {
        await _prefs.setBool(_isLoggedInKey, true);
        await saveUserDocument(currentUser.uid, userDoc.data());
        debugPrint('✅ 로그인 상태 확인됨 - Firebase 및 Firestore 데이터 존재');
      }
    } catch (e) {
      debugPrint('❌ 세션 검증 중 오류 발생: $e');
      await clearUserSession();
    }
  }

  // 언어 관련
  static String? getLanguage() {
    String? language = _prefs.getString(_languageKey);
    debugPrint('🌐 저장된 언어 설정: $language');
    return language;
  }

  static Future<void> setLanguage(String languageCode) async {
    debugPrint('🌐 언어 설정 변경: $languageCode');
    await _prefs.setString(_languageKey, languageCode);
  }

  // FCM 토큰 관련 메소드
  static Future<bool> setFCMToken(String token) async {
    return await _prefs.setString(_fcmTokenKey, token);
  }

  static String? getFCMToken() {
    return _prefs.getString(_fcmTokenKey);
  }

  static Future<bool> removeFCMToken() async {
    return await _prefs.remove(_fcmTokenKey);
  }

  // 알림 설정 관련 메서드
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  static Future<bool> removeBool(String key) async {
    return await _prefs.remove(key);
  }

  // 알림 설정 관련 헬퍼 메서드
  static bool getMatchRequestNotificationEnabled() {
    return getBool(_notificationMatchRequestsKey, defaultValue: true);
  }

  static bool getMessagesNotificationEnabled() {
    return getBool(_notificationMessagesKey, defaultValue: true);
  }

  static bool getPromotionsNotificationEnabled() {
    return getBool(_notificationPromotionsKey, defaultValue: false);
  }

  // 로그인 상태 관리
  static bool isLoggedIn() {
    final uid = getUserUid();
    final isLoggedInPref = _prefs.getBool(_isLoggedInKey) ?? false;
    return uid != null && uid.isNotEmpty && isLoggedInPref;
  }

  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
    debugPrint('🔐 로그인 상태 설정: $value');
  }

  // 사용자 문서 저장 메서드
  static Future<bool> saveUserDocument(String uid, Map<String, dynamic>? userDoc) async {
    try {
      if (userDoc != null) {
        String jsonString = userDoc.toString();
        await _prefs.setString(_userDocumentKey, jsonString);
        debugPrint('✅ 사용자 문서 저장됨');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ 사용자 문서 저장 중 오류: $e');
      return false;
    }
  }

  static String? getUserDocument() {
    return _prefs.getString(_userDocumentKey);
  }

  // 로그인 세션 관리 - 토큰 타임스탬프 추가
  static Future<bool> saveUserSession(String uid, {Map<String, dynamic>? userDoc}) async {
    try {
      debugPrint('💾 세션 저장 시작 - UID: $uid');

      List<Future<bool>> futures = [
        _prefs.setString(_userIdKey, uid),
        _prefs.setString(_userUidKey, uid),
        _prefs.setBool(_isLoggedInKey, true),
      ];

      // 토큰 타임스탬프 저장
      await updateTokenTimestamp();

      if (userDoc != null) {
        await saveUserDocument(uid, userDoc);
      }

      final results = await Future.wait(futures);
      final success = results.every((result) => result == true);

      if (success) {
        debugPrint('✅ 세션 저장 완료');
        final savedSession = getUserSession();
        debugPrint('📱 저장된 세션 정보: $savedSession');
        return true;
      } else {
        debugPrint('❌ 일부 세션 데이터 저장 실패');
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
      return true;
    }
  }

  // 로그아웃 처리
  static Future<void> logout() async {
    try {
      debugPrint('🚪 로그아웃 처리 시작');
      await clearUserSession();
      debugPrint('✅ 로그아웃 완료 (모든 세션 데이터 삭제)');
    } catch (e) {
      debugPrint('❌ 로그아웃 중 오류: $e');
    }
  }

  // 전체 세션 초기화
  static Future<void> clearUserSession() async {
    debugPrint('🧹 세션 정보 초기화 시작');
    await Future.wait([
      _prefs.remove(_userIdKey),
      _prefs.remove(_userUidKey),
      _prefs.remove(_userDocumentKey),
      _prefs.remove(_authTokenKey),
      _prefs.remove(_tokenTimestampKey), // 토큰 타임스탬프도 삭제
      _prefs.setBool(_isLoggedInKey, false),
      _prefs.remove(_fcmTokenKey),
    ]);
    debugPrint('✅ 세션 정보 초기화 완료');
  }

  static String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  static String? getUserPhone() {
    return null;
  }

  static String? getUserUid() {
    return _prefs.getString(_userUidKey);
  }

  static Map<String, dynamic>? getUserSession() {
    final uid = getUserUid();

    if (uid == null) {
      debugPrint('⚠️ 저장된 UID 없음');
      return null;
    }

    debugPrint('🔍 세션 조회 - UID: $uid');

    return {
      'userId': uid,
      'uid': uid,
      'isLoggedIn': isLoggedIn(),
    };
  }
}