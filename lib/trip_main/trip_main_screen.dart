import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';
import '../services/translation_service.dart';
import '../compents/appbar.dart';
import '../compents/settings_drawer.dart';
import '../trip_main/widgets/reservation_info_card.dart';
import '../trip_main/widgets/horizontal_reservation_cards.dart';
import '../trip_main/widgets/point_section.dart';
import '../trip_main/widgets/bottom_nav_section.dart';
import '../trip_main/widgets/trip_friends_banner.dart';
import '../trip_main/widgets/event_banner.dart';
import '../trip_main/widgets/main_footer.dart';

class MainScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  final Map<String, String> countryNames;
  final String currentLanguage;
  final Function(String) onCountryChanged;
  final VoidCallback refreshKeys;
  final TranslationService translationService;

  const MainScreen({
    super.key,
    this.onNavigateToTab,
    required this.countryNames,
    required this.currentLanguage,
    required this.onCountryChanged,
    required this.refreshKeys,
    required this.translationService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentLanguage = '';
  bool _isLoggedIn = true;
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
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

  void _handleCountryChanged(String newCountryCode) {
    widget.onCountryChanged(newCountryCode);
  }

  void _refreshKeys() {
    widget.refreshKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: TripFriendsAppBar(
        countryNames: widget.countryNames,
        currentCountryCode: _currentLanguage.isNotEmpty ?
        _currentLanguage :
        currentCountryCode,
        onCountryChanged: _handleCountryChanged,
        refreshKeys: _refreshKeys,
        isLoggedIn: _isLoggedIn,
        translationService: widget.translationService,
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