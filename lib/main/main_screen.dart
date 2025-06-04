import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../main.dart';
import '../main_page.dart';
import '../services/shared_preferences_service.dart';
import '../services/translation_service.dart';
import '../compents/appbar.dart';
import '../compents/settings_drawer.dart';
import 'widgets/reservation_info_card.dart';
import 'widgets/traveler_info_card.dart';
import 'widgets/horizontal_reservation_cards.dart';
import 'widgets/point_section.dart';
import 'widgets/bottom_nav_section.dart';
import 'widgets/trip_friends_banner.dart';
import 'widgets/event_banner.dart';
import 'widgets/main_footer.dart';

class MainScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const MainScreen({super.key, this.onNavigateToTab});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, String> countryNames = {};
  late TranslationService translationService;
  String _currentLanguage = '';
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    translationService = TranslationService();
    _currentLanguage = SharedPreferencesService.getLanguage() ?? currentCountryCode;
    loadTranslations();
  }

  Future<void> loadTranslations() async {
    try {
      String effectiveLanguage = _currentLanguage.isNotEmpty ?
      _currentLanguage :
      (SharedPreferencesService.getLanguage() ?? currentCountryCode);

      final String translationsJson = await rootBundle.loadString(
          'assets/data/country.json');
      final data = json.decode(translationsJson);

      if (mounted) {
        setState(() {
          countryNames = Map.fromEntries(
              (data['countries'] as List).map((country) {
                String countryName = effectiveLanguage.isNotEmpty &&
                    country['names'].containsKey(effectiveLanguage) ?
                country['names'][effectiveLanguage] as String :
                country['names']['KR'] as String;

                return MapEntry(country['code'] as String, countryName);
              })
          );
        });
      }
    } catch (e) {
      debugPrint('❌ 번역 로드 오류: $e');
    }
  }

  void _handleCountryChanged(String newCountryCode) {
    if (!mounted) return;

    setState(() {
      _currentLanguage = newCountryCode;
      if (currentCountryCode != newCountryCode) {
        currentCountryCode = newCountryCode;
        languageChangeController.add(newCountryCode);
      }
      loadTranslations();
    });
  }

  void _refreshKeys() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: TripFriendsAppBar(
        countryNames: countryNames,
        currentCountryCode: _currentLanguage.isNotEmpty ?
        _currentLanguage :
        currentCountryCode,
        onCountryChanged: _handleCountryChanged,
        refreshKeys: _refreshKeys,
        isLoggedIn: _isLoggedIn,
        translationService: translationService,
      ),
      endDrawer: const SettingsDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 예약 정보 카드
                const ReservationInfoCard(),

                const SizedBox(height: 12),

                // 예약 현황 카드
                const TravelerInfoCard(),

                const SizedBox(height: 12),

                // 예약/지난예약 카드 (가로 배치)
                HorizontalReservationCards(
                  onNavigateToTab: widget.onNavigateToTab,
                ),

                const SizedBox(height: 12),

                // 적립금 섹션
                const PointSection(),

                const SizedBox(height: 12),

                // 하단 네비게이션
                BottomNavSection(
                  onNavigateToTab: widget.onNavigateToTab,
                ),

                const SizedBox(height: 12),

                // 트립프렌즈 배너
                TripFriendsBanner(
                  language: _currentLanguage.isNotEmpty ? _currentLanguage : currentCountryCode,
                ),

                const SizedBox(height: 12),

                // 이벤트 배너
                const EventBanner(),

                const SizedBox(height: 40),

                // Footer
                MainFooter(
                  language: _currentLanguage.isNotEmpty ? _currentLanguage : currentCountryCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}