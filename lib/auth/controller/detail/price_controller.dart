import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../main.dart';

class PriceController {
  // 나라별 시간당 가격 정보
  Map<String, int> _pricePerHourByCountry = {};

  // 현재 선택된 시간당 가격
  int _currentPricePerHour = 1; // 기본값

  // 가격 정보 로드 함수
  Future<void> loadPricePerHourData() async {
    try {
      final String priceJson = await rootBundle.loadString('assets/data/priceperhour.json');
      final priceData = json.decode(priceJson);

      // JSON에서 가격 정보 로드
      final prices = priceData['prices'] as Map<String, dynamic>;
      _pricePerHourByCountry = prices.map((key, value) => MapEntry(key, value as int));

      print('시간당 요금 정보 로드 완료: $_pricePerHourByCountry');
    } catch (e) {
      debugPrint('Error loading price per hour data: $e');
      // 오류 발생 시 빈 맵으로 초기화 (기본값은 getPriceForCountryCode에서 처리)
      _pricePerHourByCountry = {};
    }
  }

  // 국가 코드에 따라 시간당 가격 업데이트
  int getPriceForCountryCode(String countryCode) {
    if (_pricePerHourByCountry.containsKey(countryCode)) {
      _currentPricePerHour = _pricePerHourByCountry[countryCode] ?? 1;
      print('국가 코드에 따른 시간당 요금 가져오기: $countryCode -> $_currentPricePerHour');
    } else {
      _currentPricePerHour = 1; // 기본값
      print('해당 국가 코드($countryCode)의 시간당 요금 정보 없음, 기본값 사용: 1');
    }
    return _currentPricePerHour;
  }

  // 현재 가격 반환
  int get currentPrice => _currentPricePerHour;

  // 가격 업데이트
  void updatePrice(int newPrice) {
    _currentPricePerHour = newPrice;
  }

  // 위치 정보에 따라 시간당 가격 설정
  int getPriceBasedOnLocation(String? userLocationCode) {
    String effectiveCode = userLocationCode ?? currentCountryCode;
    return getPriceForCountryCode(effectiveCode);
  }

  // 가격 형식 변환 (1,000 형식)
  String formatPrice(String price) {
    if (price.isEmpty) return '';

    // 쉼표 제거 후 숫자만 추출
    final cleanPrice = price.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPrice.isEmpty) return '';

    // 숫자를 정수로 변환
    final number = int.tryParse(cleanPrice);
    if (number == null) return '';

    // 천 단위 쉼표 형식으로 변환
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
  }

  bool isEmpty() {
    return _pricePerHourByCountry.isEmpty;
  }
}