import 'package:flutter/material.dart';
import 'logout_controller.dart';
import 'logout_popup.dart';
import '../../translations/components_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class LogoutButtonWidget extends StatefulWidget {
  final LogoutController controller;

  const LogoutButtonWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<LogoutButtonWidget> createState() => _LogoutButtonWidgetState();
}

class _LogoutButtonWidgetState extends State<LogoutButtonWidget> {
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;
    debugPrint('🔥 LogoutWidget - 초기 언어: $_currentLanguage');

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      debugPrint('🔥 LogoutWidget - 언어 변경 감지: $newLanguage');
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 디버깅을 위한 추가 로그
    debugPrint('🔥 LogoutWidget - currentCountryCode 전역 변수: $currentCountryCode');
    debugPrint('🔥 LogoutWidget - _currentLanguage 상태 변수: $_currentLanguage');

    // 번역 데이터 확인
    final translations = ComponentsTranslations.translations['logout'];
    debugPrint('🔥 LogoutWidget - logout 번역 데이터: $translations');

    final String logoutText = ComponentsTranslations.getTranslation('logout', _currentLanguage);
    debugPrint('🔥 LogoutWidget - 최종 번역된 텍스트: $logoutText');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: ShapeDecoration(
          color: const Color(0xFFEAEAEA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: InkWell(
          onTap: () => showLogoutPopup(context, widget.controller),
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              logoutText,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}