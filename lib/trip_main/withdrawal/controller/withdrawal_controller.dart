import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../translations/mypage_translations.dart';
import '../../../main.dart'; // currentCountryCode

class WithdrawalController {
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController receiverAddressController = TextEditingController();
  final TextEditingController swiftCodeController = TextEditingController();
  final TextEditingController withdrawalAmountController = TextEditingController();

  // 사용자 정보
  String userId = '';
  String point = '0';
  String currencySymbol = '₩';
  String currencyCode = 'KRW';
  String withdrawalLimit = '100,000';
  bool hasWithdrawalInfo = false;

  WithdrawalController();

  // 초기화 메서드
  Future<void> init() async {
    await loadUserData();
    await checkBankInfo();
  }

  // 사용자 데이터 로드
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      userId = user.uid;

      final userData = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;

        // DB에서 직접 필드값 가져오기
        point = data['point']?.toString() ?? '0';
        currencySymbol = data['currencySymbol'] ?? '₩';
        currencyCode = data['currencyCode'] ?? 'KRW';
        withdrawalLimit = data['withdrawalLimit']?.toString() ?? '100,000';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');

      // 오류 시 기본값 설정
      point = '0';
      currencySymbol = '₩';
      currencyCode = 'KRW';
      withdrawalLimit = '100,000';
    }
  }

  // 기존 은행 정보 확인
  Future<void> checkBankInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bankInfoDoc = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('bank_info')
          .doc('info')
          .get();

      if (bankInfoDoc.exists) {
        hasWithdrawalInfo = true;
        final data = bankInfoDoc.data() as Map<String, dynamic>;

        bankNameController.text = data['bank_name'] ?? '';
        accountNumberController.text = data['account_number'] ?? '';
        accountHolderController.text = data['account_holder'] ?? '';
        receiverAddressController.text = data['receiver_address'] ?? '';
        swiftCodeController.text = data['swift_code'] ?? '';
      } else {
        hasWithdrawalInfo = false;
      }
    } catch (e) {
      debugPrint('Error checking bank info: $e');
      hasWithdrawalInfo = false;
    }
  }

  // 은행 정보 저장
  Future<bool> saveBankInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // 입력값 검증
      if (bankNameController.text.isEmpty ||
          accountNumberController.text.isEmpty ||
          accountHolderController.text.isEmpty ||
          receiverAddressController.text.isEmpty ||
          swiftCodeController.text.isEmpty) {
        return false;
      }

      await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('bank_info')
          .doc('info')
          .set({
        'bank_name': bankNameController.text,
        'account_number': accountNumberController.text,
        'account_holder': accountHolderController.text,
        'receiver_address': receiverAddressController.text,
        'swift_code': swiftCodeController.text,
        'updated_at': FieldValue.serverTimestamp(),
      });

      hasWithdrawalInfo = true;
      return true;
    } catch (e) {
      debugPrint('Error saving bank info: $e');
      return false;
    }
  }

  // 출금 신청
  Future<String> requestWithdrawal() async {
    final language = currentCountryCode.toUpperCase();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'user_not_found';

      // 출금 금액 파싱 - 전체 포인트를 출금
      final withdrawalAmount = int.tryParse(point.replaceAll(',', '')) ?? 0;
      final minLimit = 100000; // 최소 출금 금액 100,000으로 고정

      // 최소 출금 금액(100,000) 확인
      if (withdrawalAmount < minLimit) {
        return 'below_minimum';
      }

      // 출금 정보 확인
      if (!hasWithdrawalInfo) {
        return 'no_bank_info';
      }

      // balance_history에 출금 내역 저장
      final withdrawalId = FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('balance_history')
          .doc()
          .id;

      String description = MypageTranslations.getTranslation('withdrawal_description', language);

      await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('balance_history')
          .doc(withdrawalId)
          .set({
        'amount': withdrawalAmount,
        'currency_code': currencyCode,
        'currency_symbol': currencySymbol,
        'type': 'withdrawal',
        'status': 'pending', // pending, completed, rejected
        'created_at': FieldValue.serverTimestamp(),
        'description': description,
        'bank_name': bankNameController.text,
        'account_number': accountNumberController.text,
        'account_holder': accountHolderController.text,
        'receiver_address': receiverAddressController.text,
        'swift_code': swiftCodeController.text,
      });

      // 포인트 감소 (출금 신청시 바로 차감)
      await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .update({
        'point': 0, // 모든 포인트 출금
      });

      // 사용자 데이터 리로드
      await loadUserData();

      return 'success';
    } catch (e) {
      debugPrint('Error requesting withdrawal: $e');
      return 'error';
    }
  }

  // 숫자에 콤마 추가 (포맷팅)
  String formatNumber(String text) {
    if (text.isEmpty) return '';

    final numericText = text.replaceAll(',', '');
    try {
      final numericValue = int.parse(numericText);
      return numericValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},'
      );
    } catch (e) {
      return text;
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

  // 컨트롤러 해제
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderController.dispose();
    receiverAddressController.dispose();
    swiftCodeController.dispose();
    withdrawalAmountController.dispose();
  }
}