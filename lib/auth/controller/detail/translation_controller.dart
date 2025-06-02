import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../main.dart';

class TranslationController {
  // 번역 메시지
  Map<String, String> _translatedMessages = {
    "invalid_referrer_code": "유효하지 않은 추천인 코드입니다.",
    "referrer_code_matched": "추천인 코드가 일치하였습니다.",
    "error_checking_code": "코드 확인 중 오류가 발생했습니다.",
  };

  // 기본 번역 메시지 반환
  String getTranslatedMessage(String key) {
    return _translatedMessages[key] ?? "번역 메시지를 찾을 수 없습니다.";
  }

  // 번역 데이터 로드
  Future<void> loadTranslations() async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);
      final translations = translationData['translations'];

      _translatedMessages = {
        "invalid_referrer_code": translations['invalid_referrer_code'][currentCountryCode] ??
            translations['invalid_referrer_code']['KR'] ??
            _translatedMessages['invalid_referrer_code']!,
        "referrer_code_matched": translations['referrer_code_matched'][currentCountryCode] ??
            translations['referrer_code_matched']['KR'] ??
            _translatedMessages['referrer_code_matched']!,
        "error_checking_code": translations['error_checking_code'][currentCountryCode] ??
            translations['error_checking_code']['KR'] ??
            _translatedMessages['error_checking_code']!,
      };
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }
}