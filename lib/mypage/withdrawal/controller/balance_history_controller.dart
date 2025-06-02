import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/translation_service.dart';

class BalanceHistoryController {
  final TranslationService? translationService;

  // 상태 관리
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> balanceHistory = [];

  // 사용자 정보 추가
  String currencySymbol = '₩';  // 기본값 설정

  BalanceHistoryController({this.translationService});

  // 번역 초기화
  Future<void> initTranslations() async {
    if (translationService != null) {
      await translationService!.init();
    }
  }

  // 초기화 메서드
  Future<void> init() async {
    await initTranslations();
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
    isLoading = true;
    errorMessage = '';
    balanceHistory = [];

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isLoading = false;
        errorMessage = translationService?.get('error_login_required', '로그인이 필요합니다') ?? '로그인이 필요합니다';
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
      errorMessage = translationService?.get(
          'error_loading_history',
          '적립금 내역을 불러오는 중 오류가 발생했습니다'
      ) ?? '적립금 내역을 불러오는 중 오류가 발생했습니다';
      debugPrint('적립금 내역 로드 에러: $e');
    }
  }

  // 사용자의 통화 기호 반환
  String getUserCurrencySymbol() {
    return currencySymbol;
  }

  // 거래 유형 텍스트 가져오기
  String getTypeText(String type) {
    switch (type) {
      case 'earn':
        return translationService?.get('type_earn', '적립') ?? '적립';
      case 'withdrawal':
        return translationService?.get('type_withdrawal', '출금') ?? '출금';
      default:
        return translationService?.get('type_unknown', '기타') ?? '기타';
    }
  }

// source 값에 따른 번역 텍스트 가져오기
  String getSourceText(String source) {
    switch (source) {
      case 'video_upload':
        return translationService?.get('source_video_upload', '동영상 업로드') ?? '동영상 업로드';
      case 'profile_completion':
        return translationService?.get('source_profile_completion', '프로필 완성') ?? '프로필 완성';
      case 'withdrawal':
        return translationService?.get('source_withdrawal', '적립금 출금') ?? '적립금 출금';
      case 'referral':
        return translationService?.get('source_referral', '친구 초대') ?? '친구 초대';
      case 'review':
        return translationService?.get('source_review', '리뷰 작성') ?? '리뷰 작성';
      default:
        return translationService?.get('source_unknown', '적립금 적립') ?? '적립금 적립';
    }
  }

  // 출금 상태 텍스트 가져오기 (withdrawal_status 필드가 있는 경우)
  String getWithdrawalStatusText(String status) {
    switch (status) {
      case 'pending':
        return translationService?.get('status_pending', '처리 중') ?? '처리 중';
      case 'completed':
        return translationService?.get('status_completed', '완료') ?? '완료';
      case 'rejected':
        return translationService?.get('status_rejected', '거절됨') ?? '거절됨';
      default:
        return translationService?.get('status_unknown', '알 수 없음') ?? '알 수 없음';
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