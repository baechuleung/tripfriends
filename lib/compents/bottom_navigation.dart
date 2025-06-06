// lib/compents/bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../main.dart';
import '../main/main_screen.dart';
import '../mypage/mypage.dart';
import '../globals.dart';
import '../reservation/screens/current_reservation_list_screen.dart';
import '../reservation/screens/past_reservation_list_screen.dart';
import '../chat/screens/friend_chat_list_screen.dart';
import '../services/translation_service.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget mainContent;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.mainContent,
  }) : super(key: key);

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  Map<String, dynamic> translations = {};
  String? lastCountryCode;
  bool _mounted = true;
  Map<String, String> navLabels = {
    "home": "홈",
    "reservation_list": "예약목록",
    "past_reservations": "지난예약",
    "chat_list": "채팅 리스트",
    "my_info": "내정보"
  };

  // MainScreen에서 사용할 파라미터들을 위한 더미 데이터
  final Map<String, String> _dummyCountryNames = {
    'KR': '한국',
    'VN': '베트남',
    'JP': '일본',
    'TH': '태국',
    'PH': '필리핀',
    'MY': '말레이시아'
  };

  late TranslationService _translationService;

  @override
  void initState() {
    super.initState();
    lastCountryCode = currentCountryCode;
    _translationService = TranslationService();
    loadTranslations();

    // 전역 함수에 탭 변경 함수 등록
    navigateToTab = widget.onItemSelected;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // currentCountryCode가 변경되었는지 확인
    if (lastCountryCode != currentCountryCode) {
      loadTranslations();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트될 때마다 언어 코드 변경 여부 확인
    if (lastCountryCode != currentCountryCode) {
      loadTranslations();
    }
  }

  @override
  void dispose() {
    navigateToTab = null; // 해제
    _mounted = false;
    super.dispose();
  }

  Future<void> loadTranslations() async {
    if (!_mounted) return;

    try {
      final String translationJson = await rootBundle.loadString('assets/data/bottom_translations.json');
      final translationData = json.decode(translationJson);

      if (!_mounted) return;

      setState(() {
        translations = translationData['translations'];
        lastCountryCode = currentCountryCode; // 현재 언어 코드 업데이트

        // 번역된 네비게이션 라벨 설정
        final countryCode = currentCountryCode.toUpperCase();

        if (translations.containsKey('past_reservations') &&
            translations.containsKey('reservation_list') &&
            translations.containsKey('my_info')) {

          navLabels = {
            "home": translations['home']?[countryCode] ?? "홈",
            "reservation_list": translations['reservation_list'][countryCode] ?? "예약목록",
            "past_reservations": translations['past_reservations'][countryCode] ?? "지난예약",
            "chat_list": translations['chat_list']?[countryCode] ?? "채팅 리스트",
            "my_info": translations['my_info'][countryCode] ?? "내정보"
          };
        }
      });
    } catch (e) {
      if (!_mounted) return;
      debugPrint('Error loading translations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자의 ID 가져오기
    final String userId = getUserId();

    final List<Widget> pages = [
      MainScreen(
        onNavigateToTab: widget.onItemSelected,
        countryNames: _dummyCountryNames,
        currentLanguage: currentCountryCode,
        onCountryChanged: (String newCode) {
          // BottomNavigation에서는 언어 변경을 처리하지 않음
          debugPrint('Language change requested in BottomNavigation: $newCode');
        },
        refreshKeys: () {
          // BottomNavigation에서는 키 새로고침을 처리하지 않음
          debugPrint('Refresh keys requested in BottomNavigation');
        },
        translationService: _translationService,
      ),
      const CurrentReservationListScreen(),    // 예약목록
      const PastReservationListScreen(),       // 지난 예약목록
      _buildChatListScreen(userId),            // 채팅 목록
      const MyPage(),                          // 내정보
    ];

    return Scaffold(
      body: pages[widget.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(widget.selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined),
            label: navLabels['home'],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.selectedIndex == 1 ? Icons.event_note_rounded : Icons.event_note_outlined),
            label: navLabels['reservation_list'],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.selectedIndex == 2 ? Icons.event_available_rounded : Icons.event_available_outlined),
            label: navLabels['past_reservations'],
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: navLabels['chat_list'] ?? '채팅 리스트',
              child: Icon(widget.selectedIndex == 3 ? Icons.chat_rounded : Icons.chat_outlined),
            ),
            label: navLabels['chat_list'],
          ),
          BottomNavigationBarItem(
            icon: Icon(widget.selectedIndex == 4 ? Icons.account_circle_rounded : Icons.account_circle_outlined),
            label: navLabels['my_info'],
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: const Color(0xFF5963D0),
        unselectedItemColor: Colors.grey,
        onTap: widget.onItemSelected,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // 채팅 목록 화면 빌드 함수
  Widget _buildChatListScreen(String userId) {
    // userId가 비어있으면 빈 화면 표시
    if (userId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '사용자 정보를 불러올 수 없습니다.\n다시 로그인해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    try {
      return ChatListScreen(friendsId: userId);
    } catch (e) {
      debugPrint('채팅 목록 화면 로드 오류: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '채팅 목록을 불러오는 중 오류가 발생했습니다.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
  }

  // 사용자 ID 가져오기 메서드
  String getUserId() {
    try {
      // Firebase Auth에서 현재 사용자 ID 가져오기
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return currentUser.uid;
      } else {
        debugPrint('현재 로그인된 사용자가 없습니다.');
        // 사용자가 로그인되어 있지 않으면 빈 문자열 반환
        return '';
      }
    } catch (e) {
      debugPrint('사용자 ID 가져오기 오류: $e');
      return '';
    }
  }
}