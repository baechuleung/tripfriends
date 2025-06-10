import 'package:flutter/material.dart';
import '../../compents/tripfriends_manual/screens/manual_detail_page.dart';
import '../../services/translation_service.dart';
import '../../translations/trip_main_translations.dart';

class TripFriendsBanner extends StatelessWidget {
  final String language;

  const TripFriendsBanner({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 트립프렌즈 이용방법 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManualDetailPage(
              translationService: TranslationService(),
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFFFE2E1),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  MainTranslations.getTranslation('how_to_use', language),
                  style: const TextStyle(
                    color: Color(0xFFFF3E6C),
                    fontSize: 13,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Color(0xFFFF3E6C),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}