// lib/compents/bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../trip_main/trip_main_screen.dart';
import '../mypage/mypage.dart';
import '../globals.dart';
import '../reservation/screens/current_reservation_list_screen.dart';
import '../reservation/screens/past_reservation_list_screen.dart';
import '../chat/screens/friend_chat_list_screen.dart';
import '../services/translation_service.dart';
import '../translations/components_translations.dart';

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
    updateLabels();

    // 전역 함수에 탭 변경 함수 등록
    navigateToTab = widget.onItemSelected;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // currentCountryCode가 변경되었는지 확인
    if (lastCountryCode != currentCountryCode) {
      updateLabels();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트될 때마다 언어 코드 변경 여부 확인
    if (lastCountryCode != currentCountryCode) {
      updateLabels();
    }
  }

  @override
  void dispose() {
    navigateToTab = null; // 해제
    _mounted = false;
    super.dispose();
  }

  void updateLabels() {
    if (!_mounted) return;

    setState(() {
      lastCountryCode = currentCountryCode;
      final countryCode = currentCountryCode.toUpperCase();

      navLabels = {
        "home": ComponentsTranslations.getTranslation('home', countryCode),
        "reservation_list": ComponentsTranslations.getTranslation('reservation_list', countryCode),
        "past_reservations": ComponentsTranslations.getTranslation('past_reservations', countryCode),
        "chat_list": ComponentsTranslations.getTranslation('chat_list', countryCode),
        "my_info": ComponentsTranslations.getTranslation('my_info', countryCode)
      };
    });
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
      bottomNavigationBar: Container(
        height: 75, // 높이를 80에서 75로 감소
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 6.0), // 아이콘 아래 패딩 추가
                child: Image.asset(
                  widget.selectedIndex == 0
                      ? 'assets/bottom/home_on.png'
                      : 'assets/bottom/home_off.png',
                  width: 26, // 28에서 26으로 감소
                  height: 26, // 28에서 26으로 감소
                ),
              ),
              label: navLabels['home'],
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 6.0), // 아이콘 아래 패딩 추가
                child: Image.asset(
                  widget.selectedIndex == 1
                      ? 'assets/bottom/event_note_on.png'
                      : 'assets/bottom/event_note_off.png',
                  width: 26, // 28에서 26으로 감소
                  height: 26, // 28에서 26으로 감소
                ),
              ),
              label: navLabels['reservation_list'],
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 6.0), // 아이콘 아래 패딩 추가
                child: Image.asset(
                  widget.selectedIndex == 2
                      ? 'assets/bottom/event_upcoming_on.png'
                      : 'assets/bottom/event_upcoming_off.png',
                  width: 26, // 28에서 26으로 감소
                  height: 26, // 28에서 26으로 감소
                ),
              ),
              label: navLabels['past_reservations'],
            ),
            BottomNavigationBarItem(
              icon: Tooltip(
                message: navLabels['chat_list'] ?? '채팅 리스트',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0), // 아이콘 아래 패딩 추가
                  child: Image.asset(
                    widget.selectedIndex == 3
                        ? 'assets/bottom/tooltip_on.png'
                        : 'assets/bottom/tooltip_off.png',
                    width: 26, // 28에서 26으로 감소
                    height: 26, // 28에서 26으로 감소
                  ),
                ),
              ),
              label: navLabels['chat_list'],
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 6.0), // 아이콘 아래 패딩 추가
                child: Image.asset(
                  widget.selectedIndex == 4
                      ? 'assets/bottom/account_circle_on.png'
                      : 'assets/bottom/account_circle_off.png',
                  width: 26, // 28에서 26으로 감소
                  height: 26, // 28에서 26으로 감소
                ),
              ),
              label: navLabels['my_info'],
            ),
          ],
          currentIndex: widget.selectedIndex,
          selectedItemColor: const Color(0xFF3182F6), // 선택된 아이템 색상 변경
          unselectedItemColor: const Color(0xFF999999), // 선택되지 않은 아이템 색상 변경
          selectedFontSize: 12, // 선택된 글자 크기 고정
          unselectedFontSize: 12, // 선택되지 않은 글자 크기 고정
          onTap: widget.onItemSelected,
          type: BottomNavigationBarType.fixed,
        ),
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