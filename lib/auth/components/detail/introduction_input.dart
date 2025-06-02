import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../controller/detail/register_detail_controller.dart';
import '../../../../main.dart';

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
  Map<String, String> currentLabels = {
    "introduction": "자기소개",
    "introduction_placeholder": "당신의 특별한 경험과 장점을 알려주세요.\n여행자들에게 어떤 도움을 줄 수 있는지 설명해주세요.",
    "introduction_point_info": "300자 이상 작성 시 적립금을 받을 수 있습니다.",
  };

  bool get isEligibleForPoints =>
      widget.controller.introductionController.text.trim().length >=
          RegisterDetailController.minimumIntroductionLength;

  @override
  void initState() {
    super.initState();
    loadTranslations();
    // 텍스트 변경 감지를 위한 리스너 추가
    widget.controller.introductionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 리스너 제거
    widget.controller.introductionController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // 텍스트가 변경될 때마다 화면 갱신 (포인트 지급 자격 상태 업데이트)
    setState(() {});
  }

  Future<void> loadTranslations() async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);
      final translations = translationData['translations'];

      setState(() {
        currentLabels.forEach((key, _) {
          if (translations[key] != null) {
            currentLabels[key] = translations[key][currentCountryCode] ??
                translations[key]['KR'] ??
                currentLabels[key];
          }
        });
      });
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 입력된 자기소개 텍스트 길이
    final currentLength = widget.controller.introductionController.text.trim().length;
    // 최소 필요 길이
    final requiredLength = RegisterDetailController.minimumIntroductionLength;
    // 포인트 지급 자격 여부
    final isEligible = currentLength >= requiredLength;

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
                  currentLabels['introduction']!,
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
                  color: isEligible ? Color(0xFF3182F6).withOpacity(0.5) : const Color(0xFFE5E5E5),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: widget.controller.introductionController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: currentLabels['introduction_placeholder'],
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  counterStyle: TextStyle(
                    color: isEligible ? Color(0xFF3182F6) : Color(0xFF999999),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  counterText: '$currentLength/$requiredLength',
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
                      '$currentLength/$requiredLength',
                      style: TextStyle(
                        color: isEligible ? Color(0xFF3182F6) : Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: ShapeDecoration(
                color: const Color(0xFFFF3E6C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    currentLabels['introduction_point_info']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Spoqa Han Sans Neo',
                      fontWeight: FontWeight.w700,
                    ),
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