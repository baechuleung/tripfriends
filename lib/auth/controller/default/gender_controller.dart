import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class GenderController {
  final ValueNotifier<String> genderNotifier = ValueNotifier<String>('');

  // 상태 변경 콜백
  final VoidCallback? onChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "gender": "성별",
    "male": "남성",
    "female": "여성",
  };

  GenderController({this.onChanged}) {
    genderNotifier.addListener(_notifyChanged);
  }

  void _notifyChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  String get gender => genderNotifier.value;
  set gender(String value) {
    genderNotifier.value = value;
  }

  bool hasValidGender() {
    return genderNotifier.value.isNotEmpty;
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['gender'] != null &&
          translations['male'] != null &&
          translations['female'] != null) {
        currentLabels = {
          "gender": translations['gender'][currentCountryCode],
          "male": translations['male'][currentCountryCode],
          "female": translations['female'][currentCountryCode],
        };
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    genderNotifier.dispose();
  }
}