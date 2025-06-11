import 'package:flutter/material.dart';
import '../translations/components_translations.dart';
import '../main.dart';

class TalkMainScreen extends StatelessWidget {
  const TalkMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = currentCountryCode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/main/lock.png',
            width: 64,
            height: 64,
          ),
          const SizedBox(height: 16),
          Text(
            ComponentsTranslations.getTranslation('service_preparing', language),
            style: TextStyle(
              color: const Color(0xFF1B1C1F),
              fontSize: 18,
              fontFamily: 'Spoqa Han Sans Neo',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}