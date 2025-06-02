import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class CountryDialCode {
  final String flag;
  final String dialCode;

  const CountryDialCode({required this.flag, required this.dialCode});
}

class PhoneController {
  final TextEditingController phoneController = TextEditingController();
  final ValueNotifier<String> dialCodeNotifier = ValueNotifier<String>('+82');

  // 상태 변경 콜백
  final VoidCallback? onChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "phoneVerification": "전화번호",
  };

  // 다이얼 코드 목록
  static const List<CountryDialCode> dialCodes = [
    CountryDialCode(flag: '🇰🇷', dialCode: '+82'),
    CountryDialCode(flag: '🇯🇵', dialCode: '+81'),
    CountryDialCode(flag: '🇻🇳', dialCode: '+84'),
    CountryDialCode(flag: '🇹🇭', dialCode: '+66'),
    CountryDialCode(flag: '🇹🇼', dialCode: '+886'),
    CountryDialCode(flag: '🇨🇳', dialCode: '+86'),
    CountryDialCode(flag: '🇭🇰', dialCode: '+852'),
    CountryDialCode(flag: '🇵🇭', dialCode: '+63'),
    CountryDialCode(flag: '🇬🇺', dialCode: '+1671'),
    CountryDialCode(flag: '🇸🇬', dialCode: '+65'),
  ];

  PhoneController({this.onChanged}) {
    phoneController.addListener(_notifyChanged);
    dialCodeNotifier.addListener(_notifyChanged);
  }

  void _notifyChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  String get dialCode => dialCodeNotifier.value;
  set dialCode(String code) {
    dialCodeNotifier.value = code;
  }

  String get fullPhoneNumber => '${dialCodeNotifier.value}${phoneController.text}';

  bool hasValidPhoneNumber() {
    return phoneController.text.isNotEmpty && phoneController.text.length >= 5;
  }

  Map<String, String> getPhoneData() {
    return {
      'countryCode': dialCodeNotifier.value,
      'number': phoneController.text,
    };
  }

  // 현재 선택된 국가번호 객체 가져오기
  CountryDialCode getSelectedDialCode() {
    for (var code in dialCodes) {
      if (code.dialCode == dialCodeNotifier.value) {
        return code;
      }
    }
    return dialCodes[0]; // 기본값 반환
  }

  // 국가번호 변경
  void setDialCode(CountryDialCode code) {
    dialCodeNotifier.value = code.dialCode;
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      final phoneVerification = translations['phoneVerification'];

      if (phoneVerification != null) {
        currentLabels["phoneVerification"] =
            phoneVerification[currentCountryCode] ??
                phoneVerification['KR'] ??
                "전화번호";
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    phoneController.dispose();
    dialCodeNotifier.dispose();
  }
}