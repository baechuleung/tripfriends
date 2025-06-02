import 'package:flutter/material.dart';
import '../../services/translation_service.dart';
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
    required TranslationService translationService,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, translationService),
        const SizedBox(height: 8),
        _buildInfoCard(context, data, price, currencySymbol, translationService),
      ],
    );
  }

  // 헤더 구성
  static Widget _buildHeader(BuildContext context, TranslationService translationService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildEditButton(context, translationService),
        ],
      ),
    );
  }

  // 수정 버튼
  static Widget _buildEditButton(BuildContext context, TranslationService translationService) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => _navigateToEditDetail(context),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 14, color: InfoConstants.primaryBlue),
          const SizedBox(width: 4),
          Text(
            translationService.get('edit', '수정하기'),
            style: const TextStyle(
              color: InfoConstants.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
      String currencySymbol,
      TranslationService translationService
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
          _buildLanguageSection(data['languages'], translationService),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: InfoConstants.dividerColor),
          const SizedBox(height: 16),
          data.containsKey('introduction') ? _buildIntroductionSection(data['introduction'], translationService) : const SizedBox(),
          data.containsKey('introduction') ? const SizedBox(height: 16) : const SizedBox(),
          data.containsKey('introduction') ? const Divider(height: 1, thickness: 1, color: InfoConstants.dividerColor) : const SizedBox(),
          data.containsKey('introduction') ? const SizedBox(height: 16) : const SizedBox(),
          _buildPriceSection(price, currencySymbol, translationService),
        ],
      ),
    );
  }

  // 소개 섹션 - 데이터베이스에서 가져온 정보 사용
  static Widget _buildIntroductionSection(String introduction, TranslationService translationService) {
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
              translationService.get('introduction', '소개'),
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
            color: InfoConstants.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            introduction,
            style: const TextStyle(
              color: InfoConstants.titleColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
        // 적립금 안내 텍스트를 소개글 박스 아래에 추가
        const SizedBox(height: 8),
        _buildRewardNoticeSection(translationService),
      ],
    );
  }

  // 적립금 안내 섹션
  static Widget _buildRewardNoticeSection(TranslationService translationService) {
    return StreamBuilder<QuerySnapshot>(
      stream: _infoService.getRewardHistoryStream(),
      builder: (context, snapshot) {
        // 적립금을 이미 받았는지 확인
        bool hasReward = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        // 이미 적립금을 받았으면 아무것도 표시하지 않음
        if (hasReward) {
          return const SizedBox.shrink();
        }

        // 적립금을 받지 않았으면 안내 텍스트 표시
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE), // 연한 빨간색 배경
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE57373), width: 1), // 빨간색 테두리
          ),
          child: Row(
            children: [
              const Icon(
                Icons.card_giftcard,
                size: 16,
                color: Color(0xFFE53935), // 빨간색 아이콘
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  translationService.get(
                      'profile_reward_notice',
                      '소개글 300자 이상 작성 시 ₫36,000 지급!'
                  ),
                  style: const TextStyle(
                    color: Color(0xFFD32F2F), // 진한 빨간색 텍스트
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 가격 정보 섹션
  static Widget _buildPriceSection(
      int price,
      String currencySymbol,
      TranslationService translationService
      ) {
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
              translationService.get('price_table', '나의 활동비'),
              style: const TextStyle(
                color: InfoConstants.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 시간당 요금과 10분당 요금 테이블로 표시
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: InfoConstants.dividerColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              border: TableBorder.all(
                color: InfoConstants.dividerColor,
                width: 1,
              ),
              children: [
                // 1시간 행
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        translationService.get('one_hour', '1 시간'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        '$currencySymbol $formattedPrice',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: InfoConstants.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                // 10분 행
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        translationService.get('per_10_min', '10 분당'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        '$currencySymbol $formattedPrice10Min',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: InfoConstants.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 언어 정보 섹션
  static Widget _buildLanguageSection(
      List<dynamic>? languageList,
      TranslationService translationService
      ) {
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
              translationService.get('available_languages', '사용 가능 언어'),
              style: const TextStyle(
                color: InfoConstants.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildLanguageList(languageList, translationService),
      ],
    );
  }

  // 언어 목록 렌더링
  static Widget _buildLanguageList(
      List<dynamic>? languageList,
      TranslationService translationService
      ) {
    if (languageList == null || languageList.isEmpty) {
      return const SizedBox();
    }

    try {
      List<Widget> languageWidgets = languageList.map((lang) {
        String translatedLanguage = translationService.get(
            lang.toString().toLowerCase(),
            lang.toString()
        );

        return Container(
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          padding: const EdgeInsets.all(5),
          decoration: ShapeDecoration(
            color: InfoConstants.lightBlue,
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
                  color: InfoConstants.primaryBlue,
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