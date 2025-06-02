// features/profile/utils/profile_translation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../main.dart'; // currentCountryCode 사용을 위해 import

class ProfileTranslation {
  static Map<String, String> defaultLabels = {
    "approval_complete": "승인 완료",
    "approval_waiting": "승인 대기중",
    "my_profile": "나의 프로필",
    "edit": "수정하기",
    "video_upload_reward": "영상 업로드 시 ₫54,000 지급!",
  };

  static Future<Map<String, String>> loadTranslations(String? lastCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/mypage_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      final countryCode = currentCountryCode.toUpperCase();

      final approvalComplete = translations['approval_complete'];
      final approvalWaiting = translations['approval_waiting'];
      final myProfile = translations['my_profile'];
      final edit = translations['edit'];
      final videoUploadReward = translations['video_upload_reward'];

      if (approvalComplete != null && approvalWaiting != null && myProfile != null) {
        return {
          "approval_complete": approvalComplete[countryCode],
          "approval_waiting": approvalWaiting[countryCode],
          "my_profile": myProfile[countryCode],
          "edit": edit?[countryCode] ?? "수정하기",
          "video_upload_reward": videoUploadReward?[countryCode] ?? "영상 업로드 시 ₫54,000 지급!",
        };
      }
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }

    // 오류 발생 시 기본값 반환
    return defaultLabels;
  }
}