import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../main.dart'; // currentCountryCode 가져오기 위해 추가

class CurrencyController {
  // 나라별 통화 정보
  Map<String, Map<String, String>> _currencyByCountry = {};

  // 통화 정보 로드 함수
  Future<void> loadCurrencyData() async {
    try {
      final String currencyJson = await rootBundle.loadString('assets/data/currency.json');
      final currencyData = json.decode(currencyJson);

      // JSON에서 통화 정보 로드
      final currencies = currencyData['currencies'] as Map<String, dynamic>;

      _currencyByCountry = {};
      currencies.forEach((countryCode, data) {
        if (data is Map) {
          _currencyByCountry[countryCode] = {
            'symbol': (data['symbol'] as String?) ?? '',
            'code': (data['code'] as String?) ?? '',
          };
        }
      });

      print('통화 정보 로드 완료: $_currencyByCountry');
    } catch (e) {
      debugPrint('Error loading currency data: $e');
    }
  }

  // 위치 정보에 따라 통화 정보 설정
  void setCurrencyBasedOnLocation(
      ValueNotifier<String> currencySymbolNotifier,
      ValueNotifier<String> currencyCodeNotifier,
      String? userLocationCode) {
    // userLocationCode가 없거나 일치하는 통화 정보가 없을 경우 currentCountryCode를 사용
    String effectiveCode = userLocationCode ?? currentCountryCode;

    if (_currencyByCountry.containsKey(effectiveCode)) {
      final currencyInfo = _currencyByCountry[effectiveCode]!;
      currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
      currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
      print('위치 기반 통화 정보 설정 완료: $effectiveCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
    } else {
      // 기본값 설정 (현재 국가 코드에도 매칭되는 통화 정보가 없는 경우)
      currencySymbolNotifier.value = '₩';
      currencyCodeNotifier.value = 'KRW';
      print('위치 기반 통화 정보 설정 실패, 기본값 사용: ₩ (KRW)');
    }
  }

  // 통화 심볼 업데이트
  void updateCurrencySymbol(ValueNotifier<String> currencySymbolNotifier, String symbol) {
    currencySymbolNotifier.value = symbol;
  }

  // 통화 코드 업데이트
  void updateCurrencyCode(ValueNotifier<String> currencyCodeNotifier, String code) {
    currencyCodeNotifier.value = code;
  }

  // 국가 코드로 통화 정보 가져오기
  Map<String, String>? getCurrencyForCountry(String countryCode) {
    return _currencyByCountry[countryCode];
  }

  // 현재 국가 코드에 맞는 통화 정보 가져오기 (새로 추가된 메서드)
  Map<String, String> getCurrentCountryCurrency() {
    if (_currencyByCountry.containsKey(currentCountryCode)) {
      return _currencyByCountry[currentCountryCode]!;
    }
    // 기본 한국 통화 정보 반환
    return {
      'symbol': '₩',
      'code': 'KRW'
    };
  }

  // 모든 통화 정보 가져오기
  Map<String, Map<String, String>> getAllCurrencies() {
    return _currencyByCountry;
  }

  bool isEmpty() {
    return _currencyByCountry.isEmpty;
  }
}