import 'package:flutter/material.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode
import '../../auth/edit_detail_page.dart';
import 'info_service.dart';
import 'info_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoUIComponents {
  static final InfoService _infoService = InfoService();

  // 전체 정보 레이아웃 구성
  static Widget buildInfoLayout({
    required BuildContext context,
    required Map<String, dynamic> data,
    required int price,
    required String currencySymbol,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(context, data, price, currencySymbol),
        const SizedBox(height: 16),
        _buildEditButton(context),
      ],
    );
  }

  // 수정 버튼 - logged_in_profile과 동일한 스타일
  static Widget _buildEditButton(BuildContext context) {
    final language = currentCountryCode.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () => _navigateToEditDetail(context),
        child: Container(
          width: double.infinity,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFFD9D9D9),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                MypageTranslations.getTranslation('myinfo_edit', language),
                style: TextStyle(
                  color: const Color(0xFF4E5968),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.edit,
                size: 16,
                color: const Color(0xFF4E5968),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 상세정보 수정 페이지로 이동
  static void _navigateToEditDetail(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditDetailPage(uid: user.uid),
        ),
      );
    }
  }

  // 정보 카드 구성
  static Widget _buildInfoCard(
      BuildContext context,
      Map<String, dynamic> data,
      int price,
      String currencySymbol
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLanguageSection(data['languages']),
          const SizedBox(height: 16),
          data.containsKey('introduction') ? _buildIntroductionSection(data['introduction']) : const SizedBox(),
          data.containsKey('introduction') ? const SizedBox(height: 16) : const SizedBox(),
          _buildPriceSection(price, currencySymbol),
        ],
      ),
    );
  }

  // 소개 섹션 - 데이터베이스에서 가져온 정보 사용
  static Widget _buildIntroductionSection(String introduction) {
    final language = currentCountryCode.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: const Color(0xFF3182F6),
            ),
            const SizedBox(width: 4),
            Text(
              MypageTranslations.getTranslation('introduction', language),
              style: const TextStyle(
                color: InfoConstants.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            introduction,
            style: const TextStyle(
              color: const Color(0xFF4E5968),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // 가격 정보 섹션
  static Widget _buildPriceSection(
      int price,
      String currencySymbol
      ) {
    final language = currentCountryCode.toUpperCase();
    final formattedPrice = _infoService.formatPrice(price);
    final formattedPrice10Min = _infoService.formatPrice((price / 6).round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.payments,
              size: 16,
              color: const Color(0xFF3182F6),
            ),
            const SizedBox(width: 4),
            Text(
              MypageTranslations.getTranslation('price_table', language),
              style: const TextStyle(
                color: InfoConstants.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 시간당 요금과 10분당 요금 - 하나의 박스
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // 1시간
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        MypageTranslations.getTranslation('one_hour', language),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4E5968),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currencySymbol $formattedPrice',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3182F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 60,
                color: const Color(0xFFE0E0E0),
              ),
              // 10분
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        MypageTranslations.getTranslation('per_10_min', language),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4E5968),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currencySymbol $formattedPrice10Min',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3182F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 언어 정보 섹션
  static Widget _buildLanguageSection(List<dynamic>? languageList) {
    final language = currentCountryCode.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.language,
              size: 16,
              color: const Color(0xFF3182F6),
            ),
            const SizedBox(width: 4),
            Text(
              MypageTranslations.getTranslation('available_languages', language),
              style: const TextStyle(
                color: InfoConstants.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildLanguageList(languageList),
      ],
    );
  }

  // 언어 목록 렌더링
  static Widget _buildLanguageList(List<dynamic>? languageList) {
    final language = currentCountryCode.toUpperCase();

    if (languageList == null || languageList.isEmpty) {
      return const SizedBox();
    }

    try {
      List<Widget> languageWidgets = languageList.map((lang) {
        String translatedLanguage = MypageTranslations.getTranslation(
            lang.toString().toLowerCase(),
            language
        );

        return Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.all(5),
          decoration: ShapeDecoration(
            color: const Color(0xFFF9F9F9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                translatedLanguage,
                style: const TextStyle(
                  color: const Color(0xFF4E5968),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList();

      return Wrap(
        children: languageWidgets,
      );
    } catch (e) {
      debugPrint('Error building language list: $e');
      return const SizedBox();
    }
  }
}