// lib/translations/translation_service.dart

import 'package:flutter/material.dart';
import '../main.dart'; // currentCountryCode 접근
import '../services/shared_preferences_service.dart';
import 'account_delete_translations.dart';

// 언어 변경 리스너 콜백 타입 (클래스 외부에 선언)
typedef LanguageChangeCallback = void Function();

class TranslationService {
  // 리스너 콜백 리스트
  final List<LanguageChangeCallback> _languageChangeListeners = [];

  // 리스너 추가
  void addLanguageChangeListener(LanguageChangeCallback callback) {
    _languageChangeListeners.add(callback);
  }

  // 리스너 제거
  void removeLanguageChangeListener(LanguageChangeCallback callback) {
    _languageChangeListeners.remove(callback);
  }

  // 리스너에게 언어 변경 알림
  void _notifyLanguageChanged() {
    for (var callback in _languageChangeListeners) {
      callback();
    }
  }

  // 언어 변경
  Future<void> changeLanguage(String countryCode) async {
    // SharedPreferences를 통해 언어 설정 저장
    await SharedPreferencesService.setLanguage(countryCode);

    // 전역 변수 업데이트
    currentCountryCode = countryCode;

    // 언어 변경 알림
    _notifyLanguageChanged();

    debugPrint('🌐 언어 변경됨: $countryCode');
  }

  // 번역 텍스트 가져오기
  String getTranslation(String key, String countryCode) {
    // 문자열 테이블에서 번역 가져오기
    if (AccountDeleteTranslations.translations.containsKey(key)) {
      if (AccountDeleteTranslations.translations[key]!.containsKey(countryCode)) {
        return AccountDeleteTranslations.translations[key]![countryCode]!;
      }

      // 해당 언어에 번역이 없으면 영어(SG)로 시도
      if (AccountDeleteTranslations.translations[key]!.containsKey('SG')) {
        return AccountDeleteTranslations.translations[key]!['SG']!;
      }

      // 영어도 없으면 한국어(KR)로 시도
      if (AccountDeleteTranslations.translations[key]!.containsKey('KR')) {
        return AccountDeleteTranslations.translations[key]!['KR']!;
      }
    }

    // 모든 것이 실패하면 키 자체 반환
    return key;
  }
}