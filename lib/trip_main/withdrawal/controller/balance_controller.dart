import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../translations/mypage_translations.dart';
import '../../../main.dart';  // currentCountryCode 접근을 위해 추가

class BalanceController {
  bool _isInitialized = false;

  // 잔액 관련 정보
  String point = "0";
  String currencySymbol = "₩";
  String currencyCode = "KRW";
  String withdrawalLimit = "100,000";

  BalanceController();

  // 초기화 여부 확인
  bool get isInitialized => _isInitialized;

  // 사용자 데이터 스트림 가져오기
  Stream<DocumentSnapshot> getUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 사용자가 없는 경우 빈 스트림 반환
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('tripfriends_users')
        .doc(user.uid)
        .snapshots();
  }

  // 사용자 데이터 로드
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userData = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;

        // DB에서 직접 필드값 가져오기
        point = data['point']?.toString() ?? "0";
        currencySymbol = data['currencySymbol'] ?? "₩";
        currencyCode = data['currencyCode'] ?? "KRW";

        debugPrint('사용자 데이터 로드 완료: 포인트=$point, 통화=$currencyCode');
      }

      // 출금 한도 정보도 함께 로드
      await loadWithdrawalLimits();
    } catch (e) {
      debugPrint('Error loading balance data: $e');

      // 오류 시 기본값 설정
      point = "0";
      currencySymbol = "₩";
      currencyCode = "KRW";
    }
  }

  // 출금 한도 정보 로드
  Future<void> loadWithdrawalLimits() async {
    try {
      final String response = await rootBundle.loadString('assets/data/withdrawal_limits.json');
      final data = await json.decode(response);

      // currencyCode를 직접 사용 (예: 'KRW', 'USD', 'VND' 등)
      String currency = currencyCode.toUpperCase();
      debugPrint('사용자 통화 코드: $currency');

      // JSON 파일에서 해당 통화 코드의 출금 한도 가져오기
      if (data.containsKey(currency)) {
        withdrawalLimit = data[currency]['formatted'];
        debugPrint('통화별 출금 한도: $withdrawalLimit');
      } else {
        // 기본값 설정 (한국)
        withdrawalLimit = data['KRW']['formatted'];
        debugPrint('기본 출금 한도(KRW): $withdrawalLimit');
      }
    } catch (e) {
      debugPrint('출금 한도 로드 에러: $e');
      // 오류 발생 시 기본값 유지
      withdrawalLimit = "100,000";
    }
  }

  // 적립금 형식화 (숫자에 콤마 추가)
  String getFormattedPoint() {
    try {
      final numericPoint = int.parse(point);
      return numericPoint.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},'
      );
    } catch (e) {
      return point;
    }
  }

  // 포인트 포맷팅 (widget에서 가져온 기능)
  String formatPoint(String point) {
    try {
      final numericPoint = int.parse(point);
      return numericPoint.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},'
      );
    } catch (e) {
      return point;
    }
  }

  // 현재 언어 코드 가져오기
  String getCurrentLanguage() {
    return currentCountryCode;
  }

  // 초기화 메서드
  Future<void> init() async {
    debugPrint('BalanceController 초기화 시작');
    await loadUserData();
    _isInitialized = true;
    debugPrint('BalanceController 초기화 완료');
  }
}