import 'package:flutter/material.dart';
import '../../translations/main_translations.dart';

class MainFooter extends StatelessWidget {
  final String language;

  const MainFooter({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEADPROJECT COMPANY Inc.',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${MainTranslations.getTranslation('ceo', language)}: Sangho Park | ${MainTranslations.getTranslation('cto', language)}: Chuleung Bae | ${MainTranslations.getTranslation('cdd', language)}: Yoonwoo Jung',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${MainTranslations.getTranslation('business_registration_number', language)}: 413-87-02826',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${MainTranslations.getTranslation('ecommerce_registration_number', language)}: 2024-${MainTranslations.getTranslation('seoul_gwangjin', language)}-1870',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${MainTranslations.getTranslation('tourism_business_license', language)}: 2024-000022 (${MainTranslations.getTranslation('comprehensive_travel_business', language)})',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            MainTranslations.getTranslation('achasan_address', language) + ', ' + MainTranslations.getTranslation('republic_of_korea', language),
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${MainTranslations.getTranslation('tel', language)}: 1666-5157',
            style: TextStyle(
              fontSize: 8,
              fontFamily: 'Spoqa Han Sans Neo',
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}