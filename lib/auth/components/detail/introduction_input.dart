import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../controller/detail/register_detail_controller.dart';
import '../../controller/detail/validation_controller.dart';
import '../../../../main.dart';
import '../../../../translations/auth_detail_translations.dart';

class IntroductionInput extends StatefulWidget {
  final RegisterDetailController controller;

  const IntroductionInput({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<IntroductionInput> createState() => _IntroductionInputState();
}

class _IntroductionInputState extends State<IntroductionInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.introductionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.introductionController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 현재 입력된 자기소개 텍스트 길이
    final currentLength = widget.controller.introductionController.text.trim().length;
    // 100자 이상일 때 색상 변경
    final isColorChangeEligible = currentLength >= 100;

    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 행: 자기소개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AuthDetailTranslations.getTranslation('introduction', currentCountryCode),
                  style: TextStyle(
                    color: const Color(0xFF353535),
                    fontSize: 14,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isColorChangeEligible ? Color(0xFF3182F6).withOpacity(0.5) : const Color(0xFFE5E5E5),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: widget.controller.introductionController,
                maxLines: 5,
                maxLength: 500,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(500),
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: AuthDetailTranslations.getTranslation('introduction_placeholder', currentCountryCode),
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  counterStyle: TextStyle(
                    color: isColorChangeEligible ? Color(0xFF3182F6) : Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  counterText: '$currentLength/500',
                ),
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Container(
                    margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    child: Text(
                      '$currentLength/500',
                      style: TextStyle(
                        color: isColorChangeEligible ? Color(0xFF3182F6) : Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // 100자 미만일 때 경고 메시지
            if (currentLength < 100) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Color(0xFFFF5050),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AuthDetailTranslations.getTranslation('introduction_min_length', currentCountryCode),
                      style: const TextStyle(
                        color: Color(0xFFFF5050),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '<${AuthDetailTranslations.getTranslation('introduction_writing_guide_title', currentCountryCode)}>',
                    style: const TextStyle(
                      color: Color(0xFF353535),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 자기소개 작성 안내
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.report_gmailerrorred,
                        size: 20,
                        color: Color(0xFFFF5050),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthDetailTranslations.getTranslation('introduction_writing_guide', currentCountryCode),
                              style: const TextStyle(
                                color: Color(0xFF353535),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• ${AuthDetailTranslations.getTranslation('introduction_reward_desc', currentCountryCode)}',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            Text(
                              '• ${AuthDetailTranslations.getTranslation('introduction_content_guide', currentCountryCode)}',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            Text(
                              '• ${AuthDetailTranslations.getTranslation('introduction_warning_desc', currentCountryCode)}',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            Text(
                              '• ${AuthDetailTranslations.getTranslation('introduction_ad_warning', currentCountryCode)}',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 적립금 지급 안내
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.report_gmailerrorred,
                        size: 20,
                        color: Color(0xFFFF5050),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AuthDetailTranslations.getTranslation('reward_payment_guide', currentCountryCode),
                              style: const TextStyle(
                                color: Color(0xFF353535),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• ${AuthDetailTranslations.getTranslation('reward_review_notice', currentCountryCode)}',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}