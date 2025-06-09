import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../translations/mypage_translations.dart';
import '../../../main.dart'; // currentCountryCode

class BalanceHistoryController {
  // 상태 관리
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> balanceHistory = [];

  // 사용자 정보 추가
  String currencySymbol = '₩';  // 기본값 설정

  BalanceHistoryController();

  // 초기화 메서드
  Future<void> init() async {
    await loadUserData();  // 사용자 데이터 로드 추가
    await loadBalanceHistory();
  }

  // 사용자 데이터 로드 함수 추가
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
        currencySymbol = data['currencySymbol'] ?? '₩';
        debugPrint('사용자 통화 기호 로드: $currencySymbol');
      }
    } catch (e) {
      debugPrint('사용자 데이터 로드 에러: $e');
      currencySymbol = '₩';  // 오류 시 기본값 설정
    }
  }

  // 적립금 내역 로드
  Future<void> loadBalanceHistory() async {
    final language = currentCountryCode.toUpperCase();
    isLoading = true;
    errorMessage = '';
    balanceHistory = [];

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isLoading = false;
        errorMessage = MypageTranslations.getTranslation('error_login_required', language);
        return;
      }

      // 적립금 관련 컬렉션에서 데이터 가져오기
      final historyDocs = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('balance_history')
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> history = [];

      for (final doc in historyDocs.docs) {
        final data = doc.data();

        // Timestamp를 DateTime으로 변환
        final createdAt = data['created_at'] as Timestamp?;
        final DateTime date = createdAt?.toDate() ?? DateTime.now();

        // "use" 타입은 건너뛰기
        final type = data['type'] ?? 'unknown';
        if (type == 'use') continue;

        history.add({
          'id': doc.id,
          'amount': data['amount'] ?? 0,
          'currency_symbol': data['currency_symbol'] ?? currencySymbol,  // 기본값으로 사용자 통화 사용
          'type': type,
          'created_at': date,
          'description': data['description'] ?? '',
          'source': data['source'] ?? '',
          'bank_name': data['bank_name'],
          'account_number': data['account_number'],
          'account_holder': data['account_holder'],
          'receiver_address': data['receiver_address'],
          'swift_code': data['swift_code'],
          'status': data['status'] ?? 'pending',
        });
      }

      balanceHistory = history;
      isLoading = false;
    } catch (e) {
      isLoading = false;
      errorMessage = MypageTranslations.getTranslation('error_loading_history', language);
      debugPrint('적립금 내역 로드 에러: $e');
    }
  }

  // 사용자의 통화 기호 반환
  String getUserCurrencySymbol() {
    return currencySymbol;
  }

  // 거래 유형 텍스트 가져오기
  String getTypeText(String type) {
    final language = currentCountryCode.toUpperCase();
    switch (type) {
      case 'earn':
        return MypageTranslations.getTranslation('type_earn', language);
      case 'withdrawal':
        return MypageTranslations.getTranslation('type_withdrawal', language);
      default:
        return MypageTranslations.getTranslation('type_unknown', language);
    }
  }

// source 값에 따른 번역 텍스트 가져오기
  String getSourceText(String source) {
    final language = currentCountryCode.toUpperCase();
    switch (source) {
      case 'video_upload':
        return MypageTranslations.getTranslation('source_video_upload', language);
      case 'profile_completion':
        return MypageTranslations.getTranslation('source_profile_completion', language);
      case 'withdrawal':
        return MypageTranslations.getTranslation('source_withdrawal', language);
      case 'referral':
        return MypageTranslations.getTranslation('source_referral', language);
      case 'review':
        return MypageTranslations.getTranslation('source_review', language);
      default:
        return MypageTranslations.getTranslation('source_unknown', language);
    }
  }

  // 출금 상태 텍스트 가져오기 (withdrawal_status 필드가 있는 경우)
  String getWithdrawalStatusText(String status) {
    final language = currentCountryCode.toUpperCase();
    switch (status) {
      case 'pending':
        return MypageTranslations.getTranslation('status_pending', language);
      case 'completed':
        return MypageTranslations.getTranslation('status_completed', language);
      case 'rejected':
        return MypageTranslations.getTranslation('status_rejected', language);
      default:
        return MypageTranslations.getTranslation('status_unknown', language);
    }
  }

  // 거래 유형 색상 가져오기
  Color getTypeColor(String type) {
    switch (type) {
      case 'earn':
        return Colors.green;
      case 'withdrawal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // 출금 상태 색상 가져오기
  Color getWithdrawalStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 날짜 포맷
  String formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  // 금액 포맷
  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
  }
}