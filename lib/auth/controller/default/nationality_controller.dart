import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class NationalityController {
  final TextEditingController nationalityController = TextEditingController();
  final ValueNotifier<List<Map<String, dynamic>>> countriesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<bool> isLoadingCountriesNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> countryLoadErrorNotifier = ValueNotifier<bool>(false);

  // 선택된 국가
  ValueNotifier<String?> selectedCountryNotifier = ValueNotifier<String?>(null);

  // 상태 변경 콜백
  final VoidCallback? onNationalityChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "country": "국적",
    "country_dec": "국적을 선택해주세요",
  };

  // 허용된 국가 코드 목록
  final List<String> allowedCountryCodes = [
    "KR", "JP", "VN", "TH", "TW", "CN", "HK", "PH", "GU", "SG"
  ];

  NationalityController({this.onNationalityChanged}) {
    nationalityController.addListener(_notifyNationalityChanged);
    _loadCountryList();
  }

  String get nationality => nationalityController.text;
  set nationality(String code) {
    nationalityController.text = code;
    selectedCountryNotifier.value = code;
    _notifyNationalityChanged();
  }

  List<Map<String, dynamic>> get countries => countriesNotifier.value;
  bool get isLoadingCountries => isLoadingCountriesNotifier.value;
  bool get countryLoadError => countryLoadErrorNotifier.value;

  bool hasValidNationality() {
    return nationalityController.text.isNotEmpty;
  }

  void _notifyNationalityChanged() {
    if (onNationalityChanged != null) {
      onNationalityChanged!();
    }
  }

  Future<void> _loadCountryList() async {
    try {
      isLoadingCountriesNotifier.value = true;
      countryLoadErrorNotifier.value = false;

      final String countryJson = await rootBundle.loadString('assets/data/country.json');
      final countryData = json.decode(countryJson);

      countriesNotifier.value = List<Map<String, dynamic>>.from(countryData['countries']);
      isLoadingCountriesNotifier.value = false;
      _notifyNationalityChanged();
    } catch (e) {
      debugPrint('🌍 국가 리스트 로드 오류: $e');
      countriesNotifier.value = [];
      isLoadingCountriesNotifier.value = false;
      countryLoadErrorNotifier.value = true;
      _notifyNationalityChanged();
    }
  }

  // 컨트롤러에서 들어온 값을 UI에 반영하는 로직
  void updateFromController() {
    final nationality = nationalityController.text;
    if (nationality.isEmpty) return;

    debugPrint('🌍 국적 컨트롤러 값 업데이트: $nationality');

    // 입력된 값이 직접 국가 코드인 경우 (KR, JP 등)
    if (allowedCountryCodes.contains(nationality)) {
      if (selectedCountryNotifier.value != nationality) {
        selectedCountryNotifier.value = nationality;
        debugPrint('🌍 국적 드롭다운 값 설정(코드): $nationality');
      }
      return;
    }

    // 국가 이름으로 찾기 (마이그레이션 지원)
    for (final country in countries) {
      final countryName = country['names']['KR'] as String? ??
          country['names']['EN'] as String? ??
          country['code'] as String;

      if (countryName == nationality) {
        final code = country['code'] as String;
        if (selectedCountryNotifier.value != code) {
          selectedCountryNotifier.value = code;
          // 국가 코드로 업데이트 (중요: 국가 이름이 아닌 코드가 저장됨)
          nationalityController.text = code;
          debugPrint('🌍 국적 드롭다운 값 설정(이름->코드): $code');
        }
        return;
      }
    }

    debugPrint('⚠️ 국적 매칭 실패: $nationality');
  }

  // 국가 코드로부터 표시 이름 가져오기
  String getCountryDisplayName(String countryCode, String currentCountryCode) {
    try {
      final country = countries.firstWhere(
            (c) => c['code'] == countryCode,
        orElse: () => {'names': {}, 'code': countryCode},
      );

      return country['names'][currentCountryCode] as String? ??
          country['names']['EN'] as String? ??
          countryCode;
    } catch (e) {
      return countryCode;
    }
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['country'] != null && translations['country_dec'] != null) {
        currentLabels = {
          "country": translations['country'][currentCountryCode],
          "country_dec": translations['country_dec'][currentCountryCode],
        };
      }
    } catch (e) {
      debugPrint('🌐 번역 로드 오류: $e');
    }
  }

  void dispose() {
    nationalityController.dispose();
    countriesNotifier.dispose();
    isLoadingCountriesNotifier.dispose();
    countryLoadErrorNotifier.dispose();
    selectedCountryNotifier.dispose();
  }
}