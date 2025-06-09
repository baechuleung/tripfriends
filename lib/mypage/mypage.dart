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

class MyPage extends StatefulWidget {
  const MyPage({super.key});
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, String> countryNames = {};
  Key _profileKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadTranslations();
    SharedPreferencesService.validateAndCleanSession();
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
    );
  }
}