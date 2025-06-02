// date_translations.dart
import '../../../services/translation_service.dart';

class DateTranslations {
  final TranslationService _translationService;

  DateTranslations(this._translationService);

  // 년, 월, 일 단어만 번역
  String translateDateFormat(String koreanDate) {
    if (koreanDate.isEmpty) {
      return '';
    }

    // '년', '월', '일' 단어만 번역 키를 통해 변환
    String translatedDate = koreanDate
        .replaceAll('년', _translationService.get('year_unit', '년'))
        .replaceAll('월', _translationService.get('month_unit', '월'))
        .replaceAll('일', _translationService.get('day_unit', '일'));

    return translatedDate;
  }
}