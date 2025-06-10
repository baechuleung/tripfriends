import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../main.dart';  // currentCountryCode 사용을 위해
import 'shared_preferences_service.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();

  factory TranslationService() {
    return _instance;
  }

  TranslationService._internal() {
    // 첫 인스턴스 생성 시 초기화 호출
    init();
  }

  Map<String, dynamic> _translations = {};
  String? _lastCountryCode;
  bool _isLoaded = false;
  bool _isLoading = false;

  // 언어 변경 리스너를 등록할 콜백 목록
  final List<VoidCallback> _languageChangeListeners = [];

  // 언어 변경 리스너 추가
  void addLanguageChangeListener(VoidCallback listener) {
    if (!_languageChangeListeners.contains(listener)) {
      _languageChangeListeners.add(listener);
    }
  }

  // 언어 변경 리스너 제거
  void removeLanguageChangeListener(VoidCallback listener) {
    _languageChangeListeners.remove(listener);
  }

  // 모든 리스너에게 언어 변경 알림
  void _notifyLanguageChange() {
    for (final listener in _languageChangeListeners) {
      listener();
    }
  }

  Future<void> init() async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      // 1. SharedPreferences에서 저장된 언어 설정 확인
      String? savedLanguage = SharedPreferencesService.getLanguage();

      // 2. savedLanguage와 currentCountryCode 비교
      if (savedLanguage != null && savedLanguage != currentCountryCode) {
        debugPrint('🔄 TranslationService: 저장된 언어($savedLanguage)와 현재 코드($currentCountryCode)가 다릅니다');
        // currentCountryCode 업데이트 필요 - 이 부분은 main.dart에서 관리되는 변수
      }

      String effectiveCountryCode = savedLanguage ?? currentCountryCode;

      // 3. 번역 데이터가 로드되지 않았거나 국가 코드가 변경되었다면 다시 로드
      if (!_isLoaded || _lastCountryCode != effectiveCountryCode) {
        debugPrint('📚 TranslationService: 번역 데이터 로드 중... (언어: $effectiveCountryCode)');
        await loadAllTranslations();
        _isLoaded = true;
        _lastCountryCode = effectiveCountryCode;

        // 언어 변경 리스너에게 알림
        _notifyLanguageChange();
      }
    } catch (e) {
      debugPrint('❌ TranslationService 초기화 오류: $e');
    } finally {
      _isLoading = false;
    }
  }

  // 현재 적용된 언어 코드 반환
  String getCurrentLanguage() {
    // SharedPreferences에서 저장된 설정 우선 사용
    String? savedLanguage = SharedPreferencesService.getLanguage();
    return savedLanguage ?? currentCountryCode;
  }

  // 언어 변경 메서드
  Future<void> changeLanguage(String languageCode) async {
    if (_lastCountryCode == languageCode) return;

    await SharedPreferencesService.setLanguage(languageCode);
    _lastCountryCode = languageCode;

    // 변경 후 번역 다시 로드
    await loadAllTranslations();

    // 언어 변경 리스너에게 알림
    _notifyLanguageChange();
  }

  Future<void> loadAllTranslations() async {
    try {
      // 로드할 모든 JSON 파일 리스트
      final List<String> translationFiles = [
        'assets/data/auth_translations.json',
        'assets/data/city.json',
        'assets/data/country.json',
        'assets/data/currency.json',
        'assets/data/translations.json',
        'assets/data/support.json',
        'assets/data/chat.json',
        'assets/data/main.json',
        'assets/data/match.json',
        'assets/data/manual.json',
        'assets/data/withdrawal.json',
        'assets/data/terms.json',
        'assets/data/settings_drawer.json',
        'assets/data/email_translations.json'
      ];

      Map<String, dynamic> allTranslations = {};

      for (String filePath in translationFiles) {
        try {
          final String jsonContent = await rootBundle.loadString(filePath);
          final Map<String, dynamic> fileData = json.decode(jsonContent);

          if (fileData.containsKey('translations')) {
            Map<String, dynamic> fileTranslations = fileData['translations'];
            fileTranslations.forEach((key, value) {
              allTranslations[key] = value;
            });
          }
        } catch (e) {
          debugPrint('⚠️ 번역 파일 로드 실패 $filePath: $e');
        }
      }

      _translations = allTranslations;
      debugPrint('✅ 전체 번역 데이터 로드 완료, 항목 수: ${_translations.length}');
    } catch (e) {
      debugPrint('❌ 번역 로드 오류: $e');
    }
  }

  String get(String key, String defaultValue) {
    try {
      // 현재 언어 코드 가져오기 (SharedPreferences 우선)
      String? savedLanguage = SharedPreferencesService.getLanguage();
      final countryCode = (savedLanguage ?? currentCountryCode).toUpperCase();

      return _translations[key]?[countryCode] ?? defaultValue;
    } catch (e) {
      debugPrint('❌ 번역 가져오기 오류 (키: $key): $e');
      return defaultValue;
    }
  }

  String translateContent(String key, dynamic content) {
    if (content == null) return '-';

    if (content is String) {
      return get(content.toLowerCase(), content);
    }

    if (content is List) {
      return formatListToString(content);
    }

    return content.toString();
  }

  String formatListToString(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '';
    return list.map((item) {
      String translatedItem = get(item.toString().toLowerCase(), item.toString());
      return '• $translatedItem';
    }).join('\n');
  }
}