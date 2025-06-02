import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class CityController {
  final TextEditingController cityController = TextEditingController();
  final ValueNotifier<bool> isLoadingCitiesNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> cityLoadErrorNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<Map<String, dynamic>>> citiesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  // 선택된 도시
  ValueNotifier<String?> selectedCityNotifier = ValueNotifier<String?>(null);

  // 상태 변경 콜백
  final VoidCallback? onCityChanged;

  // 국가 컨트롤러 참조
  final TextEditingController countryController;

  // 번역 관련
  Map<String, String> currentLabels = {
    "city": "도시",
    "city_dec": "도시를 선택해주세요",
    "select_country_first": "국가를 먼저 선택해주세요",
    "loading_cities": "도시 목록 로딩 중...",
    "no_cities_found": "도시 정보를 찾을 수 없습니다"
  };

  CityController({
    required this.countryController,
    this.onCityChanged,
  }) {
    cityController.addListener(_notifyCityChanged);
    countryController.addListener(_updateCityList);
    _updateCityList();
  }

  String get city => cityController.text;
  set city(String code) {
    cityController.text = code;
    selectedCityNotifier.value = code;
    _notifyCityChanged();
  }

  List<Map<String, dynamic>> get cities => citiesNotifier.value;
  bool get isLoadingCities => isLoadingCitiesNotifier.value;
  bool get cityLoadError => cityLoadErrorNotifier.value;

  bool hasValidCity() {
    return cityController.text.isNotEmpty;
  }

  void _notifyCityChanged() {
    if (onCityChanged != null) {
      onCityChanged!();
    }
  }

  Future<void> _updateCityList() async {
    final countryCode = countryController.text;

    if (countryCode.isEmpty) {
      citiesNotifier.value = [];
      cityController.text = '';
      selectedCityNotifier.value = null;
      isLoadingCitiesNotifier.value = false;
      cityLoadErrorNotifier.value = false;
      return;
    }

    try {
      isLoadingCitiesNotifier.value = true;
      cityLoadErrorNotifier.value = false;

      final String cityJson = await rootBundle.loadString('assets/data/city/$countryCode.json');
      final cityData = json.decode(cityJson);

      citiesNotifier.value = List<Map<String, dynamic>>.from(cityData['cities']);
      isLoadingCitiesNotifier.value = false;

      if (cityController.text.isNotEmpty &&
          !citiesNotifier.value.any((city) => city['code'] == cityController.text)) {
        cityController.text = '';
        selectedCityNotifier.value = null;
      }

      _notifyCityChanged();
    } catch (e) {
      citiesNotifier.value = [];
      isLoadingCitiesNotifier.value = false;
      cityLoadErrorNotifier.value = true;
      cityController.text = '';
      selectedCityNotifier.value = null;
      _notifyCityChanged();
    }
  }

  // 컨트롤러에서 들어온 값을 UI에 반영하는 로직
  void updateFromController() {
    final city = cityController.text;
    if (city.isEmpty) return;

    print('🏙️ 도시 컨트롤러 값 업데이트: $city');

    if (selectedCityNotifier.value != city) {
      selectedCityNotifier.value = city;
      print('🏙️ 도시 드롭다운 값 설정: $city');
    }
  }

  // 도시 이름 가져오기
  String getCityDisplayName(String cityCode, String currentCountryCode) {
    try {
      final city = cities.firstWhere(
            (c) => c['code'] == cityCode,
        orElse: () => {'names': {}, 'code': cityCode},
      );

      return city['names'][currentCountryCode] as String? ??
          city['names']['EN'] as String? ??
          cityCode;
    } catch (e) {
      return cityCode;
    }
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['city'] != null) {
        currentLabels['city'] = translations['city'][currentCountryCode] ?? "도시";
      }
      if (translations['city_dec'] != null) {
        currentLabels['city_dec'] = translations['city_dec'][currentCountryCode] ?? "도시를 선택해주세요";
      }
      if (translations['select_country_first'] != null) {
        currentLabels['select_country_first'] = translations['select_country_first'][currentCountryCode] ?? "국가를 먼저 선택해주세요";
      }
      if (translations['loading_cities'] != null) {
        currentLabels['loading_cities'] = translations['loading_cities'][currentCountryCode] ?? "도시 목록 로딩 중...";
      }
      if (translations['no_cities_found'] != null) {
        currentLabels['no_cities_found'] = translations['no_cities_found'][currentCountryCode] ?? "도시 정보를 찾을 수 없습니다";
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    cityController.dispose();
    isLoadingCitiesNotifier.dispose();
    cityLoadErrorNotifier.dispose();
    citiesNotifier.dispose();
    selectedCityNotifier.dispose();
  }
}