import 'package:flutter/material.dart';

class ValidationController {
  static const int minimumIntroductionLength = 300;

  // 입력 필드 유효성 검사
  bool isValid({
    required List<String> selectedLanguages,
    required String price,
    required String introduction,
  }) {
    return selectedLanguages.isNotEmpty &&
        price.isNotEmpty &&
        introduction.isNotEmpty;
  }

  // 자기소개 글자수가 포인트 지급 조건을 충족하는지 확인
  bool isIntroductionEligibleForPoints(String introduction) {
    return introduction.trim().length >= minimumIntroductionLength;
  }

  // 포인트 지급 조건 확인 및 로그 출력
  void logPointsSkipReason(bool isDetailCompletedBefore, String introduction) {
    if (isDetailCompletedBefore) {
      print('⚠️ 이미 프로필이 완성되어 있어 적립금 지급 건너뜀');
    } else if (!isIntroductionEligibleForPoints(introduction)) {
      print('⚠️ 자기소개 길이가 부족하여 적립금 지급 건너뜀 (${introduction.trim().length}/${minimumIntroductionLength})');
    }
  }
}