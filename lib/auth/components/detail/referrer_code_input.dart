import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../controller/detail/register_detail_controller.dart';
import '../../../../main.dart';

class ReferrerCodeInput extends StatefulWidget {
  final RegisterDetailController controller;
  final bool isEditMode;

  const ReferrerCodeInput({
    Key? key,
    required this.controller,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<ReferrerCodeInput> createState() => _ReferrerCodeInputState();
}

class _ReferrerCodeInputState extends State<ReferrerCodeInput> {
  Map<String, String> currentLabels = {
    "referrer_code": "추천인 코드",
    "enter_referrer_code": "추천인 코드를 입력해주세요",
    "confirm": "확인",
    "referrer_info": "추천인 정보",
    "no_referrer": "추천인 없음",
    "referrer_code_matched": "추천인 코드가 확인되었습니다", // 추가
  };

  String? referrerName;
  bool hasExistingReferrer = false;

  @override
  void initState() {
    super.initState();
    loadTranslations();
    checkExistingReferrer();
  }

  // 추천인 정보가 이미 있는지 확인
  void checkExistingReferrer() {
    try {
      if (widget.isEditMode) {
        // 비동기로 추천인 정보 확인
        Future.delayed(Duration.zero, () {
          if (mounted) {
            // EditDetailController 어댑터 확인
            final adapter = widget.controller;
            bool hasReferrer = false;
            String? name;

            // referrerInfoNotifier가 있는지 확인 (EditDetailControllerAdapter 타입일 경우)
            if (adapter.runtimeType.toString().contains("RegisterDetailControllerAdapter")) {
              try {
                final adapterWithInfo = adapter as dynamic;
                final info = adapterWithInfo.referrerInfoNotifier.value;
                hasReferrer = info is Map && info.isNotEmpty;
                if (hasReferrer) {
                  name = info['name'];
                }
                print("추천인 정보 확인 결과: $hasReferrer, 이름: $name");
              } catch (e) {
                print("추천인 정보 접근 오류: $e");
              }
            }

            // 추천인 코드가 이미 입력되어 있는지 확인
            final hasSuccess = widget.controller.referrerCodeSuccessNotifier.value != null;
            final hasText = widget.controller.referrerCodeController.text.isNotEmpty;

            setState(() {
              hasExistingReferrer = hasReferrer || hasSuccess || hasText;
              referrerName = name;
              print("추천인 존재 여부 설정: $hasExistingReferrer, 이름: $referrerName");
            });
          }
        });
      }
    } catch (e) {
      print('기존 추천인 확인 중 오류: $e');
    }
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
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditMode
                  ? currentLabels['referrer_info']!
                  : currentLabels['referrer_code']!,
              style: const TextStyle(
                color: Color(0xFF353535),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // 추천인 정보 또는 입력 폼 표시
            ValueListenableBuilder<String?>(
              valueListenable: widget.controller.referrerCodeSuccessNotifier,
              builder: (context, success, _) {
                // 성공 메시지가 있는 경우는 추천인 코드가 입력됐다는 의미
                final hasSuccessMessage = success != null;

                // 추천인 정보 확인 - EditDetailControllerAdapter 타입일 경우
                bool hasReferrerInfo = false;
                String? displayName;

                if (widget.controller.runtimeType.toString().contains("RegisterDetailControllerAdapter")) {
                  try {
                    final adapter = widget.controller as dynamic;
                    final info = adapter.referrerInfoNotifier.value;
                    hasReferrerInfo = info is Map && info.isNotEmpty;
                    if (hasReferrerInfo) {
                      displayName = info['name'];
                    }
                  } catch (e) {
                    print("추천인 정보 접근 오류: $e");
                  }
                }

                // success가 있거나(코드 성공) hasExistingReferrer가 참이거나 referrerInfo가 있으면 추천인 정보 표시
                if (hasSuccessMessage || hasExistingReferrer || hasReferrerInfo) {
                  // 추천인 정보 표시
                  return _buildReferrerInfoDisplay(displayName);
                } else {
                  // 추천인 입력폼 표시
                  return _buildCodeInputForm(widget.controller);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 추천인 정보 표시
  Widget _buildReferrerInfoDisplay([String? displayName]) {
    // 표시할 이름 결정 (우선순위: 매개변수 > referrerName > 성공 메시지 > 텍스트 컨트롤러 값)
    final nameToDisplay = displayName ??
        referrerName ??
        (widget.controller.referrerCodeSuccessNotifier.value != null ?
        currentLabels['referrer_code_matched'] ?? "추천인 코드가 확인되었습니다" : // 수정된 부분
        widget.controller.referrerCodeController.text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            size: 16,
            color: Color(0xFF3182F6),
          ),
          const SizedBox(width: 8),
          Text(
            nameToDisplay,
            style: const TextStyle(
              color: Color(0xFF353535),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 코드 입력 폼
  Widget _buildCodeInputForm(RegisterDetailController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: controller.referrerCodeController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    hintText: currentLabels['enter_referrer_code'],
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: controller.isCheckingReferrerCode,
              builder: (context, isChecking, _) {
                return SizedBox(
                  height: 45,
                  child: TextButton(
                    onPressed: isChecking
                        ? null
                        : () async {
                      await controller.validateReferrerCode(
                        controller.referrerCodeController.text,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F2FF),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: isChecking
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF237AFF),
                        ),
                      ),
                    )
                        : Text(
                      currentLabels['confirm']!,
                      style: const TextStyle(
                        color: Color(0xFF237AFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        ValueListenableBuilder<String?>(
          valueListenable: controller.referrerCodeErrorNotifier,
          builder: (context, error, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: controller.referrerCodeSuccessNotifier,
              builder: (context, success, _) {
                if (error == null && success == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error ?? success!,
                    style: TextStyle(
                      color: error != null ? const Color(0xFFFF5050) : const Color(0xFF00AA00),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}