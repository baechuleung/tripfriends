// lib/reservation/widgets/common/time_price_service.dart
import '../../../services/translation_service.dart';

class TimePriceService {
  final TranslationService translationService;

  TimePriceService(this.translationService);

  // 도시 코드에 따른 시간대 오프셋 가져오기 (UTC 기준)
  int getTimezoneOffset(String cityCode) {
    // 베트남 도시들 (UTC+7)
    if ([
      'DNN', // 다낭
      'NPT', // 나트랑
      'DAD', // 달랏
      'PQC', // 푸꾸옥
      'HAN', // 하노이
      'HLB', // 하룽베이
      'HCM', // 호치민
      'MNE', // 무이네
      'SPA', // 사파
      'HPH', // 하이퐁
    ].contains(cityCode)) {
      return 7; // UTC+7
    }

    // 홍콩, 타이완, 마카오, 중국 (UTC+8)
    else if ([
      'HKG', // 홍콩
      'TPE', // 타이페이
    ].contains(cityCode)) {
      return 8; // UTC+8
    }

    // 한국, 일본 (UTC+9)
    else if ([
      'SEL', // 서울
      'TYO', // 도쿄
    ].contains(cityCode)) {
      return 9; // UTC+9
    }

    // 태국, 캄보디아 (UTC+7)
    else if ([
      'BKK', // 방콕
      'REP', // 시엠립
    ].contains(cityCode)) {
      return 7; // UTC+7
    }

    // 기본값은 한국 시간
    else {
      return 9; // UTC+9
    }
  }

  // 예약 시간과 해당 도시 현지 시간 사이의 차이 계산 - 도시 시간 기준
  String calculateTimeRemaining(String useDate, String startTime, String cityCode) {
    try {
      // 예약 날짜 파싱 (2025년 5월 7일 형식 가정)
      final dateParts = useDate.replaceAll('년 ', '-').replaceAll('월 ', '-').replaceAll('일', '').split('-');
      final year = int.parse(dateParts[0].trim());
      final month = int.parse(dateParts[1].trim());
      final day = int.parse(dateParts[2].trim());

      // 예약 시간 파싱 (9:35 PM 형식 가정)
      int hour = 0;
      int minute = 0;

      if (startTime.contains('PM') && !startTime.startsWith('12')) {
        hour = int.parse(startTime.split(':')[0].trim()) + 12;
      } else if (startTime.contains('AM') && startTime.startsWith('12')) {
        hour = 0;
      } else {
        hour = int.parse(startTime.split(':')[0].trim());
      }

      minute = int.parse(startTime.split(':')[1].split(' ')[0].trim());

      // 시스템 현재 시간 (기기 시간대 기준)
      final localNow = DateTime.now();

      // 예약 시간 생성 (그대로 유지)
      final reservationDateTime = DateTime(year, month, day, hour, minute);

      // 현재 시간을 도시 시간으로 변환 (기기 로컬 시간 → UTC → 도시 시간)
      // 1. 기기의 로컬 시간대 오프셋 구하기
      final localOffset = localNow.timeZoneOffset.inHours;

      // 2. 도시의 시간대 오프셋 구하기
      final cityOffset = getTimezoneOffset(cityCode);

      // 3. 로컬 시간을 UTC로 변환 후 도시 시간으로 변환
      final utcTime = localNow.subtract(Duration(hours: localOffset));
      final cityNow = utcTime.add(Duration(hours: cityOffset));

      // 디버그 출력
      print('로컬 시간대: UTC+$localOffset');
      print('도시 시간대: UTC+$cityOffset');
      print('기기 로컬 시간: $localNow');
      print('변환된 도시 시간: $cityNow');
      print('예약 시간: $reservationDateTime');

      // 시간 차이 계산 (도시 시간 기준)
      final difference = reservationDateTime.difference(cityNow);
      print('시간 차이(분): ${difference.inMinutes}');

      // 결과 생성
      if (difference.isNegative) {
        return '${_formatDuration(-difference)} ${translationService.get("time_passed", "경과")}';
      } else {
        return '${_formatDuration(difference)} ${translationService.get("time_remaining", "남음")}';
      }
    } catch (e) {
      print('시간 차이 계산 오류: $e');
      return '';
    }
  }

  // 시간 간격 포맷팅 - 항상 분까지 표시
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}${translationService.get("days", "일")} ${duration.inHours % 24}${translationService.get("hours", "시간")} ${duration.inMinutes % 60}${translationService.get("minutes", "분")}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}${translationService.get("hours", "시간")} ${duration.inMinutes % 60}${translationService.get("minutes", "분")}';
    } else {
      return '${duration.inMinutes}${translationService.get("minutes", "분")}';
    }
  }

  // 실시간 요금 및 이용 시간을 계산하는 메서드
  Map<String, dynamic> calculateRealTimePrice({
    required String status,
    required int pricePerHour,
    required String useDate,
    required String startTime,
    required String cityCode,
  }) {
    // 결과를 저장할 맵
    Map<String, dynamic> result = {
      'realTimePrice': 0.0,
      'usedTime': '0분', // 기본값
    };

    // pending 상태인 경우: 기본 요금과 0분 이용 시간
    if (status == 'pending') {
      result['realTimePrice'] = pricePerHour;
      result['usedTime'] = '0${translationService.get("minutes", "분")}';
      return result;
    }

    // in_progress 상태인 경우: 시간 계산 필요
    if (status == 'in_progress') {
      try {
        // 예약 날짜 파싱 (2025년 5월 7일 형식 가정)
        final dateParts = useDate.replaceAll('년 ', '-').replaceAll('월 ', '-').replaceAll('일', '').split('-');
        final year = int.parse(dateParts[0].trim());
        final month = int.parse(dateParts[1].trim());
        final day = int.parse(dateParts[2].trim());

        // 예약 시간 파싱 (9:35 PM 형식 가정)
        int hour = 0;
        int minute = 0;

        if (startTime.contains('PM') && !startTime.startsWith('12')) {
          hour = int.parse(startTime.split(':')[0].trim()) + 12;
        } else if (startTime.contains('AM') && startTime.startsWith('12')) {
          hour = 0;
        } else {
          hour = int.parse(startTime.split(':')[0].trim());
        }

        minute = int.parse(startTime.split(':')[1].split(' ')[0].trim());

        // 예약 시작 시간 생성
        final startDateTime = DateTime(year, month, day, hour, minute);

        // 현재 시간을 도시 시간으로 변환 (기기 로컬 시간 → UTC → 도시 시간)
        // 1. 기기의 로컬 시간대 오프셋 구하기
        final localNow = DateTime.now();
        final localOffset = localNow.timeZoneOffset.inHours;

        // 2. 도시의 시간대 오프셋 구하기
        final cityOffset = getTimezoneOffset(cityCode);

        // 3. 로컬 시간을 UTC로 변환 후 도시 시간으로 변환
        final utcTime = localNow.subtract(Duration(hours: localOffset));
        final cityNow = utcTime.add(Duration(hours: cityOffset));

        // 사용 시간 계산 (분 단위)
        final usedMinutes = cityNow.difference(startDateTime).inMinutes;

        // 음수 시간 처리 (아직 예약 시간이 되지 않은 경우)
        if (usedMinutes <= 0) {
          result['realTimePrice'] = pricePerHour;
          result['usedTime'] = '0${translationService.get("minutes", "분")}';
          return result;
        }

        // 사용 시간 및 요금 계산
        final hours = usedMinutes ~/ 60; // 온전한 시간
        final remainingMinutes = usedMinutes % 60; // 남은 분

        // 요금 계산
        double totalPrice = 0.0;

        if (hours < 1) {
          // 1시간 미만: 기본 시간당 요금 적용
          totalPrice = pricePerHour.toDouble();
        } else {
          // 1시간 이상: 기본 시간당 요금 + 추가 시간 요금
          totalPrice = pricePerHour.toDouble(); // 첫 1시간

          // 1시간 이후 추가 분에 대한 요금 (10분 단위로 계산)
          int additionalMinutes = (hours - 1) * 60 + remainingMinutes;
          int tenMinuteBlocks = (additionalMinutes / 10).ceil(); // 10분 블록 수 (올림)
          totalPrice += (pricePerHour.toDouble() / 6) * tenMinuteBlocks;
        }

        // 사용 시간 문자열 형식으로 변환
        String usedTimeStr = '';
        if (hours > 0) {
          usedTimeStr = '${hours}${translationService.get("hours", "시간")} ';
        }
        usedTimeStr += '${remainingMinutes}${translationService.get("minutes", "분")}';

        result['realTimePrice'] = totalPrice.toInt(); // 정수형으로 변환
        result['usedTime'] = usedTimeStr;
        return result;
      } catch (e) {
        print('실시간 요금 계산 오류: $e');
        // 오류 발생 시 기본값 반환
        result['realTimePrice'] = pricePerHour;
        result['usedTime'] = '0${translationService.get("minutes", "분")}';
        return result;
      }
    }

    // 기타 상태인 경우 기본값 반환
    return result;
  }

  // 가격을 포맷팅하는 메서드
  String formatPrice(dynamic price, String currencySymbol) {
    // 숫자형으로 변환 (int 혹은 double이 들어올 수 있음)
    double priceValue = price is int ? price.toDouble() : (price is double ? price : 0.0);
    // 소수점 이하 자릿수 처리
    String formattedPrice = priceValue.toStringAsFixed(priceValue.truncateToDouble() == priceValue ? 0 : 2);

    // 천 단위 구분자 추가
    final parts = formattedPrice.split('.');
    parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},');

    // 통화 기호와 함께 반환
    return '$currencySymbol ${parts.join('.')}';
  }
}