import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralValidationResult {
  final bool isValid;
  final String? referrerUid;

  ReferralValidationResult({required this.isValid, this.referrerUid});
}

class ReferralController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 추천인 코드 유효성 검사
  Future<ReferralValidationResult> validateReferrerCode(String code, String currentUserId) async {
    if (code.isEmpty) {
      return ReferralValidationResult(isValid: false);
    }

    try {
      // 자기 자신의 추천인 코드인지 먼저 확인
      final currentUserDoc = await _firestore
          .collection("tripfriends_users")
          .doc(currentUserId)
          .get();

      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
        final myReferrerCode = currentUserData['referrer_code'];

        if (myReferrerCode == code) {
          print('자기 자신의 추천인 코드를 입력했습니다.');
          return ReferralValidationResult(isValid: false);
        }
      }

      // 다른 사용자의 추천인 코드 확인
      final querySnapshot = await _firestore
          .collection("tripfriends_users")
          .where("referrer_code", isEqualTo: code)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return ReferralValidationResult(isValid: false);
      }

      return ReferralValidationResult(
        isValid: true,
        referrerUid: querySnapshot.docs.first.id,
      );
    } catch (e) {
      print('추천인 코드 검증 중 오류: $e');
      return ReferralValidationResult(isValid: false);
    }
  }

  // 추천인 승인 정보 업데이트
  Future<void> updateReferrerApproval(String currentUid,
      String referrerUid,
      String referrerCode,
      Map<String, dynamic> updateData) async {
    // 추천인 문서에 추천 받은 사람(현재 유저) 정보 추가 - 클라이언트 시간 사용
    final now = Timestamp.now();
    final approvalMap = {
      "uid": currentUid,
      "approved_at": now
    };

    // referrer_approval 필드 업데이트
    final referrerDoc = await _firestore.collection("tripfriends_users").doc(
        referrerUid).get();
    final referrerData = referrerDoc.data() as Map<String, dynamic>;

    if (referrerData.containsKey('referrer_approval') &&
        referrerData['referrer_approval'] is List) {
      // 기존 배열에서 현재 UID와 관련된 항목을 제거 (중복 방지)
      List<dynamic> currentApprovals = List.from(
          referrerData['referrer_approval']);
      currentApprovals.removeWhere((item) =>
      item is Map && item['uid'] == currentUid ||
          item == currentUid // 기존 형식이 단순 UID 문자열인 경우도 처리
      );

      // 새로운 형식의 맵 추가
      currentApprovals.add(approvalMap);

      // 업데이트
      await referrerDoc.reference.update({
        "referrer_approval": currentApprovals
      });
    } else {
      // referrer_approval 필드가 없거나 배열이 아닌 경우 새로 생성
      await referrerDoc.reference.update({
        "referrer_approval": [approvalMap]
      });
    }

    // 현재 유저의 문서에 추천인 정보 추가 - updateData에 포함
    // 클라이언트 시간 사용
    final validatedNow = Timestamp.now();
    updateData["referrer"] = {
      "uid": referrerUid,
      "code": referrerCode,
      "validated_at": validatedNow // 클라이언트 시간 사용
    };
  }
}