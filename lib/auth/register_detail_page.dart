import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller/detail/register_detail_controller.dart';
import 'components/detail/languages.dart';
import 'components/detail/referrer_code_input.dart';
import 'components/detail/introduction_input.dart';
import '../services/translation_service.dart';
import 'register_page.dart';

class RegisterDetailPage extends StatefulWidget {
  final String uid;

  const RegisterDetailPage({
    super.key,
    required this.uid,
  });

  @override
  _RegisterDetailPageState createState() => _RegisterDetailPageState();
}

class _RegisterDetailPageState extends State<RegisterDetailPage> {
  late final RegisterDetailController _controller;
  final TranslationService _translationService = TranslationService();

  Map<String, String> currentLabels = {
    "register": "회원가입",
    "complete": "완료",
  };

  @override
  void initState() {
    super.initState();
    _controller = RegisterDetailController(uid: widget.uid);
    _initTranslations();
    _controller.loadExistingData();
  }

  Future<void> _initTranslations() async {
    try {
      await _translationService.init();
      setState(() {
        currentLabels["register"] = _translationService.get("register", "회원가입");
        currentLabels["complete"] = _translationService.get("complete", "완료");
      });
    } catch (e) {
      debugPrint('Translation initialization error: $e');
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF353535)),
            onPressed: () {
              // 키보드 닫기
              FocusScope.of(context).unfocus();

              // Navigator 스택 확인 후 안전하게 처리
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // 돌아갈 페이지가 없으면 RegisterPage로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(uid: widget.uid),
                  ),
                );
              }
            },
          ),
          centerTitle: true,
          title: Text(
            currentLabels['register'] ?? '회원가입',
            style: const TextStyle(
              color: Color(0xFF353535),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Languages(controller: _controller),
                const SizedBox(height: 16),
                // PriceSlider 컴포넌트 삭제 - 이제 국가 코드에 따라 자동으로 설정됨
                IntroductionInput(controller: _controller),
                const SizedBox(height: 16),
                ReferrerCodeInput(controller: _controller),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _controller.isSavingNotifier,
                    builder: (context, isSaving, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _controller.isValidNotifier,
                        builder: (context, isValid, _) {
                          return ElevatedButton(
                            onPressed: (!isValid || isSaving)
                                ? null
                                : () async {
                              try {
                                await _controller.updateDetails(context);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_translationService.get('save_failed', '저장 실패: $e')),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3182F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              disabledBackgroundColor: const Color(0xFFE5E5E5),
                            ),
                            child: isSaving
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              currentLabels['complete']!,
                              style: TextStyle(
                                color: isValid ? Colors.white : const Color(0xFF999999),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}