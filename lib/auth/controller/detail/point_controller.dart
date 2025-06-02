import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/point_util.dart';

class PointController {
  // Firebase 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 기존 포인트 값 가져오기
  Future<int> getExistingPointValue(String uid) async {
    try {
      final docSnapshot = await _firestore.collection("tripfriends_users").doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('point')) {
          final pointValue = data['point'];
          print('💰 기존 포인트 값 가져오기: $pointValue');
          return (pointValue is int) ? pointValue : 0;
        }
      }
      print('💰 기존 포인트 값 없음, 0 반환');
      return 0;
    } catch (e) {
      print('❌ 기존 포인트 값 가져오기 실패: $e');
      return 0;
    }
  }

  // 프로필 완성 시 포인트 지급 (PointUtil 사용)
  Future<void> addProfileCompletionPoints(
      String uid,
      String currencyCode,
      int introductionLength
      ) async {
    try {
      print('💰 프로필 완성 포인트 지급 시작 - UID: $uid, 통화코드: $currencyCode, 자기소개 길이: $introductionLength자');

      // PointUtil의 메서드 호출
      await PointUtil.addProfileCompletionPoints(uid, currencyCode);

      print('✅ 프로필 완성 포인트 지급 완료');
    } catch (e) {
      print('❌ 프로필 완성 포인트 지급 실패: $e');
      throw e;
    }
  }

  // 추천인 포인트 지급
  Future<void> addReferralPoints(
      String referrerUid,
      String referredUserName,
      String referrerCurrencyCode
      ) async {
    await PointUtil.addReferralPoints(
        referrerUid: referrerUid,
        referredUserName: referredUserName,
        currencyCode: referrerCurrencyCode
    );
  }
}