import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InfoService {
  // 사용자 데이터에서 필요한 정보만 추출하여 구조화
  Map<String, dynamic> parseUserData(Map<String, dynamic> data) {
    return {
      'languages': data['languages'] is List
          ? List<dynamic>.from(data['languages'])
          : <dynamic>[],
      'introduction': data['introduction'] as String? ?? '',
    };
  }

  // 사용자 데이터에서 가격 정보 추출
  int getPriceFromData(Map<String, dynamic> data) {
    return data['pricePerHour'] ?? 10000;
  }

  // 사용자 데이터에서 통화 기호 추출
  String getCurrencyFromData(Map<String, dynamic> data) {
    return data['currencySymbol'] ?? '₩';
  }

  // 천 단위 구분자 추가
  String formatPrice(int price) {
    return price.toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
  }

  // 소개글이 적립금 조건을 충족하는지 확인 (300자 이상)
  bool isIntroductionEligibleForReward(String introduction) {
    return introduction.length >= 300;
  }

  // 적립금 내역 스트림 가져오기
  Stream<QuerySnapshot> getRewardHistoryStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('tripfriends_users')
        .doc(user.uid)
        .collection('balance_history')
        .where('source', isEqualTo: 'profile_completion')
        .limit(1)
        .snapshots();
  }

  // 적립금 상태 텍스트 가져오기
  String getRewardStatusText({
    required bool isEligible,
    required bool hasReward,
    required String eligibleText,
    required String notEligibleText,
  }) {
    if (!isEligible) {
      return notEligibleText;
    } else if (!hasReward) {
      return eligibleText;
    } else {
      return '';
    }
  }
}