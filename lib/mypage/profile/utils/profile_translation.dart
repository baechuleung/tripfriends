// features/profile/utils/profile_translation.dart
import 'package:flutter/material.dart';
import '../../../translations/mypage_translations.dart';
import '../../../main.dart'; // currentCountryCode 사용을 위해 import

class ProfileTranslation {
  static Map<String, String> defaultLabels = {
    "approval_complete": "승인 완료",
    "approval_waiting": "승인 대기중",
    "my_profile": "나의 프로필",
    "edit": "수정하기",
  };

  static Future<Map<String, String>> loadTranslations(String? lastCountryCode) async {
    try {
      final countryCode = currentCountryCode.toUpperCase();

      return {
        "approval_complete": MypageTranslations.getTranslation('approval_complete', countryCode),
        "approval_waiting": MypageTranslations.getTranslation('approval_waiting', countryCode),
        "my_profile": MypageTranslations.getTranslation('my_profile', countryCode),
        "edit": MypageTranslations.getTranslation('edit', countryCode),
      };
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }

    // 오류 발생 시 기본값 반환
    return defaultLabels;
  }
}