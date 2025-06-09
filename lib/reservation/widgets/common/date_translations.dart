// date_translations.dart
import '../../../translations/reservation_translations.dart';

class DateTranslations {
  final String currentLanguage;

  DateTranslations(this.currentLanguage);

  // 년, 월, 일 단어만 번역
  String translateDateFormat(String koreanDate) {
    if (koreanDate.isEmpty) {
      return '';
    }

    // '년', '월', '일' 단어만 번역 키를 통해 변환
    String translatedDate = koreanDate
        .replaceAll('년', ReservationTranslations.getTranslation('year_unit', currentLanguage))
        .replaceAll('월', ReservationTranslations.getTranslation('month_unit', currentLanguage))
        .replaceAll('일', ReservationTranslations.getTranslation('day_unit', currentLanguage));

    return translatedDate;
  }
}