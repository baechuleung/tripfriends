// lib/google_translation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../main.dart'; // 국가 코드를 가져오기 위한 임포트

class GoogleTranslationService {
  // 싱글톤 패턴 구현
  static final GoogleTranslationService _instance = GoogleTranslationService._internal();
  factory GoogleTranslationService() => _instance;
  GoogleTranslationService._internal();

  // Google Translation API 사용
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';

  // API 키 - .env 파일에서 가져오기
  static String get _apiKey => dotenv.env['GOOGLE_TRANSLATION_API_KEY'] ?? '';

  // 언어 코드 매핑 (ISO 국가 코드 -> Google 번역 언어 코드)
  final Map<String, String> _countryToLanguageCode = {
    'KR': 'ko',
    'US': 'en',
    'JP': 'ja',
    'CN': 'zh-CN',
    'TW': 'zh-TW',
    'GB': 'en',
    'FR': 'fr',
    'DE': 'de',
    'ES': 'es',
    'IT': 'it',
    'RU': 'ru',
    'TH': 'th',
    'VN': 'vi',
    // 필요에 따라 추가
  };

  // 번역 요청 함수
  Future<String> translateText(String text, {String? targetLanguage}) async {
    try {
      // main.dart에서 설정된 국가 코드 가져오기
      String countryCode = currentCountryCode; // main.dart에서 export된 전역 변수

      // 국가 코드를 언어 코드로 변환
      String languageCode = targetLanguage ??
          _countryToLanguageCode[countryCode] ?? 'en';

      // 번역할 텍스트가 없는 경우 그대로 반환
      if (text.isEmpty) {
        return text;
      }

      // HTTP 요청 보내기
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'target': languageCode,
        }),
      );

      // 응답 확인
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;

        if (translations.isNotEmpty) {
          return translations[0]['translatedText'];
        }
      }

      // 에러 로깅
      debugPrint('번역 API 오류: ${response.statusCode} - ${response.body}');
      return text; // 실패 시 원본 텍스트 반환
    } catch (e) {
      debugPrint('번역 오류: $e');
      return text; // 예외 발생 시 원본 텍스트 반환
    }
  }

  // 현재 언어 코드 가져오기
  String getCurrentLanguageCode() {
    String countryCode = currentCountryCode;
    return _countryToLanguageCode[countryCode] ?? 'en';
  }
}