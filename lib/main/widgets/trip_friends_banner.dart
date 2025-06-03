import 'package:flutter/material.dart';
import '../../compents/tripfriends_manual/screens/manual_detail_page.dart';
import '../../services/translation_service.dart';

class TripFriendsBanner extends StatelessWidget {
  const TripFriendsBanner({super.key});

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
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage('assets/main/main_banner.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
            const Positioned(
              left: 16,
              top: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tìm hiếu về',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
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
            const Positioned(
              right: 16,
              bottom: 16,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 30,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
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