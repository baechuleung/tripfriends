import 'package:flutter/material.dart';
import '../../services/translation_service.dart';
import 'recommended_friends_page.dart';

class RecommendedFriendsButtonWidget extends StatelessWidget {
  final TranslationService? translationService;

  const RecommendedFriendsButtonWidget({
    Key? key,
    this.translationService,
  }) : super(key: key);

  String _getTranslatedText(String key, String defaultText) {
    if (translationService == null) {
      return defaultText;
    }
    return translationService!.get(key, defaultText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F3FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecommendedFriendsPage(
                translationService: translationService,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(
                'assets/waving_hand.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTranslatedText('recommended_friends', '추천 프렌즈'),
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _getTranslatedText(
                        'recommended_friends_desc',
                        '나를 추천한 친구들의 목록을 확인하세요!',
                      ),
                      style: const TextStyle(
                        color: Color(0xFF7269F7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: Color(0xFF7269F7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}