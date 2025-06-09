import 'package:flutter/material.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode
import 'recommended_friends_page.dart';

class RecommendedFriendsButtonWidget extends StatelessWidget {
  const RecommendedFriendsButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = currentCountryCode.toUpperCase();

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
              builder: (context) => const RecommendedFriendsPage(),
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
                      MypageTranslations.getTranslation('recommended_friends', language),
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      MypageTranslations.getTranslation('recommended_friends_desc', language),
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