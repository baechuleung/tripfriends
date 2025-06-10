import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../main.dart';
import 'profile/widgets/logged_in_profile.dart';
import '../services/shared_preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mypage/tripfriends_info/info_widget.dart';
import 'recommended_friends/recommended_friends_button_widget.dart';
import 'active/active_toggle_widget.dart';
import '../translations/mypage_translations.dart';
import 'dart:async';

class MyPage extends StatefulWidget {
  const MyPage({super.key});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, String> countryNames = {};
  Key _profileKey = UniqueKey();
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;
    loadTranslations();
    SharedPreferencesService.validateAndCleanSession();

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });
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
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF353535),
            size: 20,
          ),
          onPressed: () {
            // MainPage의 홈 탭(인덱스 0)으로 이동
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
                  (route) => false,
            );
          },
        ),
        titleSpacing: 0,
        title: Text(
          MypageTranslations.getTranslation('my_page', _currentLanguage),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF353535),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E5E5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
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
                      const ActiveToggleWidget(), // Active 토글 위젯 추가
                      const SizedBox(height: 16),
                      const InfoWidget(),
                      const SizedBox(height: 16),
                      const RecommendedFriendsButtonWidget(),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}