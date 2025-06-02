import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class NameController {
  final TextEditingController nameController = TextEditingController();

  // 상태 변경 콜백
  final VoidCallback? onChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "name": "이름",
    "name_dec": "실명으로 입력해주세요",
  };

  NameController({this.onChanged}) {
    nameController.addListener(_notifyChanged);
  }

  void _notifyChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  String get name => nameController.text;
  set name(String value) {
    nameController.text = value;
  }

  bool hasValidName() {
    return nameController.text.isNotEmpty;
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['name'] != null && translations['name_dec'] != null) {
        currentLabels = {
          "name": translations['name'][currentCountryCode],
          "name_dec": translations['name_dec'][currentCountryCode],
        };
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    nameController.dispose();
  }
}