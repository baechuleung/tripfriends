import 'package:flutter/material.dart';
import '../../compents/tripfriends_manual/screens/manual_detail_page.dart';
import '../../services/translation_service.dart';
import '../../translations/main_translations.dart';

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
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/main/main_banner.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MainTranslations.getTranslation('learn_about', language),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'Trip Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}