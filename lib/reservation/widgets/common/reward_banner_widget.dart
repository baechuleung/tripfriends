import 'package:flutter/material.dart';
import '../../../translations/reservation_translations.dart';
import '../../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class RewardBannerWidget extends StatefulWidget {
  const RewardBannerWidget({Key? key}) : super(key: key);

  @override
  State<RewardBannerWidget> createState() => _RewardBannerWidgetState();
}

class _RewardBannerWidgetState extends State<RewardBannerWidget> {
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 첫 번째 줄: 핀 아이콘과 적립금 지급 안내
          Row(
            children: [
              const Icon(
                Icons.push_pin,
                color: Color(0xFFFF3E6C),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                ReservationTranslations.getTranslation('reward_info_title', _currentLanguage),
                style: const TextStyle(
                  color: Color(0xFF4E5968),
                  fontSize: 13,
                  fontFamily: 'Spoqa Han Sans Neo',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 두 번째 줄: 설명 텍스트
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ReservationTranslations.getTranslation('reward_info_desc_1', _currentLanguage),
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 13,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
                TextSpan(
                  text: ReservationTranslations.getTranslation('reward_amount', _currentLanguage),
                  style: const TextStyle(
                    color: Color(0xFFFF3E6C),
                    fontSize: 13,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                TextSpan(
                  text: ReservationTranslations.getTranslation('reward_info_desc_2', _currentLanguage),
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 13,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}