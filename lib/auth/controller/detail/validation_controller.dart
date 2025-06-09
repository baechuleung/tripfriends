import 'package:flutter/material.dart';

class ValidationController {
  static const int minimumIntroductionLength = 100;

  // 입력 필드 유효성 검사
  bool isValid({
    required List<String> selectedLanguages,
    required String price,
    required String introduction,
  }) {
    return selectedLanguages.isNotEmpty &&
        price.isNotEmpty &&
        introduction.trim().length >= minimumIntroductionLength;
  }
}