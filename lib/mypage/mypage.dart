import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../main.dart';
import 'profile/widgets/logged_in_profile.dart'; // profile.dart 대신 logged_in_profile.dart에서 가져오기
import '../services/shared_preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mypage/tripfriends_info/info_widget.dart';
import '../services/translation_service.dart'; // TranslationService 임포트 추가
import 'recommended_friends/recommended_friends_button_widget.dart'; // 나를 추천한 친구들 버튼 위젯 임포트 추가
import 'withdrawal/widgets/balance_card_widget.dart'; // balance_card_widget 추가
import 'withdrawal/controller/balance_controller.dart'; // balance_controller 추가
import '../compents/logout/logout_controller.dart'; // 로그아웃 컨트롤러 추가
import '../compents/logout/logout_widget.dart'; // 로그아웃 위젯 추가
import 'active/active_toggle_widget.dart'; // Active 토글 위젯 추가

class MyPage extends StatefulWidget {
  const MyPage({super.key});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, String> countryNames = {};
  Key _profileKey = UniqueKey();
  final TranslationService _translationService = TranslationService(); // TranslationService 인스턴스 생성
  late BalanceController _balanceController; // balance_controller 인스턴스 추가
  late LogoutController _logoutController; // 로그아웃 컨트롤러 인스턴스 추가

  @override
  void initState() {
    super.initState();
    loadTranslations();
    _initTranslationService(); // TranslationService 초기화 메소드 호출
    SharedPreferencesService.validateAndCleanSession();

    // balance_controller 초기화 추가
    _balanceController = BalanceController();
    _balanceController.init();

    // 로그아웃 컨트롤러 초기화
    _logoutController = LogoutController();
  }

  // TranslationService 초기화 메소드 추가
  Future<void> _initTranslationService() async {
    try {
      await _translationService.init();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing translation service: $e');
    }
  }

  Future<void> loadTranslations() async {
    try {
      final String translationsJson = await rootBundle.loadString('assets/data/country.json');
      final data = json.decode(translationsJson);
      setState(() {
        countryNames = Map.fromEntries(
            (data['countries'] as List).map((country) =>
                MapEntry(country['code'] as String, country['names'][currentCountryCode] as String)
            )
        );
      });
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  @override
  void dispose() {
    // 컨트롤러 해제 (필요한 경우)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0), // 상하 패딩만 16으로 설정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (snapshot.hasData && snapshot.data != null) ...[
                  // 로그인 상태
                  LoggedInProfileWidget(key: _profileKey),
                  const SizedBox(height: 16),
                  ActiveToggleWidget(
                    translationService: _translationService,
                  ), // Active 토글 위젯 추가
                  const SizedBox(height: 16),
                  const InfoWidget(),
                  const SizedBox(height: 16),
                  RecommendedFriendsButtonWidget(translationService: _translationService),
                  const SizedBox(height: 16),
                  BalanceCardWidget(controller: _balanceController),
                  const SizedBox(height: 24),
                  LogoutButtonWidget(
                    controller: _logoutController,
                    translationService: _translationService,
                  ), // 번역 서비스가 적용된 로그아웃 버튼 추가
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}