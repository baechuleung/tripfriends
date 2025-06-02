import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AgeController {
  final TextEditingController birthYearController = TextEditingController();
  final TextEditingController birthMonthController = TextEditingController();
  final TextEditingController birthDayController = TextEditingController();

  // 상태 변경 콜백
  final VoidCallback? onChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "age": "생년월일",
    "age_dec": "생년월일을 선택해주세요",
    "year": "년도",
    "year_suffix": "년",
    "month": "월",
    "month_suffix": "월",
    "day": "일",
    "day_suffix": "일"
  };

  // 선택된 값들
  ValueNotifier<int?> selectedYearNotifier = ValueNotifier<int?>(null);
  ValueNotifier<int?> selectedMonthNotifier = ValueNotifier<int?>(null);
  ValueNotifier<int?> selectedDayNotifier = ValueNotifier<int?>(null);

  // 드롭다운 옵션들
  List<int> years = [];
  List<int> months = List.generate(12, (index) => index + 1);
  late ValueNotifier<List<int>> daysNotifier;

  AgeController({this.onChanged}) {
    daysNotifier = ValueNotifier<List<int>>(List.generate(31, (index) => index + 1));
    birthYearController.addListener(_notifyChanged);
    birthMonthController.addListener(_notifyChanged);
    birthDayController.addListener(_notifyChanged);
    _initializeYears();
  }

  void _initializeYears() {
    final currentYear = DateTime.now().year;
    years = List.generate(100, (index) => currentYear - index);
  }

  void _notifyChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  bool hasValidAge() {
    return birthYearController.text.isNotEmpty &&
        birthMonthController.text.isNotEmpty &&
        birthDayController.text.isNotEmpty;
  }

  Map<String, dynamic> getBirthDateMap() {
    return {
      "year": int.tryParse(birthYearController.text) ?? 0,
      "month": int.tryParse(birthMonthController.text) ?? 0,
      "day": int.tryParse(birthDayController.text) ?? 0,
    };
  }

  // 컨트롤러에서 들어온 값을 UI에 반영하는 로직
  void updateFromController() {
    try {
      final yearText = birthYearController.text;
      final monthText = birthMonthController.text;
      final dayText = birthDayController.text;

      int? yearValue = yearText.isNotEmpty ? int.tryParse(yearText) : null;
      int? monthValue = monthText.isNotEmpty ? int.tryParse(monthText) : null;
      int? dayValue = dayText.isNotEmpty ? int.tryParse(dayText) : null;

      selectedYearNotifier.value = yearValue;
      selectedMonthNotifier.value = monthValue;
      selectedDayNotifier.value = dayValue;

      // 월이 선택되면 해당 월의 일 수에 맞게 업데이트
      if (yearValue != null && monthValue != null) {
        _updateDays(yearValue, monthValue);
      }
    } catch (e) {
      print('❌ 생년월일 값 파싱 오류: $e');
    }
  }

  void _updateDays(int? year, int? month) {
    if (year == null || month == null) {
      daysNotifier.value = List.generate(31, (index) => index + 1);
      return;
    }

    var daysInMonth = DateTime(year, month + 1, 0).day;
    daysNotifier.value = List.generate(daysInMonth, (index) => index + 1);

    // 현재 선택된 날짜가 새로운 월의 일 수보다 크면 null로 재설정
    if (selectedDayNotifier.value != null &&
        selectedDayNotifier.value! > daysInMonth) {
      selectedDayNotifier.value = null;
      birthDayController.text = '';
    }
  }

  void updateBirthDate(int? year, int? month, int? day) {
    if (year != null) {
      selectedYearNotifier.value = year;
      birthYearController.text = year.toString();
    }

    if (month != null) {
      selectedMonthNotifier.value = month;
      birthMonthController.text = month.toString().padLeft(2, '0');

      // 월이 변경될 때 일 목록 업데이트
      if (year != null) {
        _updateDays(year, month);
      }
    }

    if (day != null) {
      selectedDayNotifier.value = day;
      birthDayController.text = day.toString().padLeft(2, '0');
    }
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['age'] != null &&
          translations['age_dec'] != null &&
          translations['year'] != null &&
          translations['year_suffix'] != null &&
          translations['month'] != null &&
          translations['month_suffix'] != null &&
          translations['day'] != null &&
          translations['day_suffix'] != null) {
        currentLabels = {
          "age": translations['age'][currentCountryCode],
          "age_dec": translations['age_dec'][currentCountryCode],
          "year": translations['year'][currentCountryCode],
          "year_suffix": translations['year_suffix'][currentCountryCode],
          "month": translations['month'][currentCountryCode],
          "month_suffix": translations['month_suffix'][currentCountryCode],
          "day": translations['day'][currentCountryCode],
          "day_suffix": translations['day_suffix'][currentCountryCode],
        };
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    birthYearController.dispose();
    birthMonthController.dispose();
    birthDayController.dispose();
    selectedYearNotifier.dispose();
    selectedMonthNotifier.dispose();
    selectedDayNotifier.dispose();
    daysNotifier.dispose();
  }
}