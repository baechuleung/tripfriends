// auth/controller/referral/referral_controller.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ReferralController {
  final FirebaseFirestore _firestore;
  final ValueNotifier<String?> referralCodeNotifier = ValueNotifier<String?>(null);

  ReferralController({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // 8자리 숫자 추천 코드 생성
  String _generateReferralCode() {
    final random = Random();
    String code = '';

    // 첫 자리는 0이 아닌 숫자로 시작
    code += (random.nextInt(9) + 1).toString();

    // 나머지 7자리 생성
    for (int i = 0; i < 7; i++) {
      code += random.nextInt(10).toString();
    }

    return code;
  }

  // 코드 중복 검사
  Future<bool> _isReferralCodeExists(String code) async {
    // referralCode에서 referrer_code로 필드명 변경
    final snapshot = await _firestore
        .collection("tripfriends_users")
        .where("referrer_code", isEqualTo: code)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // 고유한 추천 코드 생성
  Future<String> generateUniqueReferralCode() async {
    String code = _generateReferralCode();
    bool exists = await _isReferralCodeExists(code);

    // 중복 검사 - 존재하면 다시 생성
    while (exists) {
      code = _generateReferralCode();
      exists = await _isReferralCodeExists(code);
    }

    // 코드 저장
    referralCodeNotifier.value = code;
    return code;
  }

  void dispose() {
    referralCodeNotifier.dispose();
  }
}