// register_completion_dialog.dart
import 'package:flutter/material.dart';
import '../main_page.dart';
import '../main.dart';  // currentCountryCode를 위한 import
import '../services/translation_service.dart';  // TranslationService 임포트

class RegisterCompletionDialog extends StatefulWidget {
  const RegisterCompletionDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const RegisterCompletionDialog();
      },
    );
  }

  @override
  State<RegisterCompletionDialog> createState() => _RegisterCompletionDialogState();
}

class _RegisterCompletionDialogState extends State<RegisterCompletionDialog> {
  final TranslationService _translationService = TranslationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    setState(() {
      _isLoading = true;
    });

    await _translationService.init();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 국가 코드가 변경된 경우 번역 다시 로드
    _translationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 축하 이모지
            const Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            // 제목
            Text(
              _translationService.get('congratulations', '축하합니다!'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF353535),
              ),
            ),
            const SizedBox(height: 8),
            // 내용
            Text(
              _translationService.get('registration_complete', '회원가입이 완료되었습니다.'),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                        (Route<dynamic> route) => false, // 모든 이전 라우트 제거
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3182F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  _translationService.get('confirm', '확인'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}