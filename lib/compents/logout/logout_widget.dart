import 'package:flutter/material.dart';
import 'logout_controller.dart';
import '../../services/translation_service.dart'; // 번역 서비스 추가

class LogoutButtonWidget extends StatelessWidget {
  final LogoutController controller;
  final TranslationService? translationService; // 번역 서비스 추가

  const LogoutButtonWidget({
    Key? key,
    required this.controller,
    this.translationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 기존 translation_service의 get 메서드를 사용
    final String logoutText = translationService?.get('logout', '로그아웃') ?? '로그아웃';

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
          onTap: () => controller.logout(context),
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