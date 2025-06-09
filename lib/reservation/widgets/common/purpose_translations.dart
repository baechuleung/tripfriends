// purpose_translations.dart
import '../../../translations/reservation_translations.dart';

class PurposeTranslations {
  final String currentLanguage;

  PurposeTranslations(this.currentLanguage);

  // 한국어 목적 텍스트에 대한 번역 키 매핑
  Map<String, String> getPurposeKeys() {
    return {
      '맛집/카페 탐방': 'restaurant_cafe_tour',
      '전통시장/쇼핑탐방': 'market_shopping_tour',
      '문화/관광지 체험': 'culture_tour',
      '밤거리 동행': 'night_companion',
      '자유일정 동행/통역': 'free_schedule_companion',
      '긴급 생활지원': 'emergency_support',
      '기타': 'other'
    };
  }

  // 한국어 목적 텍스트를 번역 키로 변환
  String getTranslationKey(String koreanText) {
    final purposeKeys = getPurposeKeys();
    return purposeKeys[koreanText] ?? 'other';
  }

  // 단일 목적 번역
  String translatePurpose(String koreanPurpose) {
    // 한국어 텍스트를 번역 키로 변환
    String translationKey = getTranslationKey(koreanPurpose);

    // 번역 키를 사용하여 현재 언어로 번역
    return ReservationTranslations.getTranslation(translationKey, currentLanguage);
  }

  // 목적 목록을 번역된 텍스트로 변환
  String translatePurposeList(List<String> purposes) {
    if (purposes.isEmpty) {
      return ReservationTranslations.getTranslation('no_purpose_specified', currentLanguage);
    }

    // 각 한국어 목적을 현재 언어로 번역
    List<String> translatedPurposes = purposes.map((koreanPurpose) =>
        translatePurpose(koreanPurpose)
    ).toList();

    return translatedPurposes.join(', ');
  }
}