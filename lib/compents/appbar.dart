// appbar.dart
import 'package:flutter/material.dart';
import '../services/shared_preferences_service.dart';
import '../services/translation_service.dart';

class TripFriendsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, String> countryNames;
  final String currentCountryCode;
  final Function(String) onCountryChanged;
  final VoidCallback refreshKeys;
  final TranslationService? translationService;
  final bool isLoggedIn;  // 로그인 상태 확인용 파라미터 추가

  const TripFriendsAppBar({
    Key? key,
    required this.countryNames,
    required this.currentCountryCode,
    required this.onCountryChanged,
    required this.refreshKeys,
    required this.isLoggedIn,  // required 파라미터로 추가
    this.translationService,
  }) : super(key: key);

  @override
  Size get preferredSize {
    // 앱바 기본 높이만 사용
    return const Size.fromHeight(kToolbarHeight);
  }

  @override
  State<TripFriendsAppBar> createState() => _TripFriendsAppBarState();
}

class _TripFriendsAppBarState extends State<TripFriendsAppBar> {
  late TranslationService _translationService;
  String _displayCountryCode = 'KR'; // 기본값으로 초기화

  @override
  void initState() {
    super.initState();
    _translationService = widget.translationService ?? TranslationService();

    // 언어 변경을 감지하는 리스너 등록
    _translationService.addLanguageChangeListener(_onLanguageChanged);

    // 위젯이 마운트된 후 언어 설정 확인 및 적용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDisplayLanguage();
    });
  }

  @override
  void didUpdateWidget(TripFriendsAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 위젯이 업데이트될 때 (예: 부모에서 currentCountryCode가 변경될 때) 언어 설정 확인
    if (oldWidget.currentCountryCode != widget.currentCountryCode) {
      _updateDisplayLanguage();
    }
  }

  // 언어 변경 리스너 콜백
  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        _updateDisplayLanguage();
      });
    }
  }

  // 표시 언어 업데이트
  void _updateDisplayLanguage() {
    // SharedPreferences에서 최신 언어 설정 확인
    String? savedLanguage = SharedPreferencesService.getLanguage();

    // 위젯에 전달된 currentCountryCode와 저장된 설정 비교
    if (savedLanguage != null && savedLanguage != widget.currentCountryCode) {
      debugPrint('📢 AppBar: 언어 설정 불일치 감지 - 저장됨: $savedLanguage, 위젯: ${widget.currentCountryCode}');

      // onCountryChanged 콜백을 통해 부모 위젯에 알림
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCountryChanged(savedLanguage);
      });
    }

    setState(() {
      // 표시할 국가 코드 결정 (비어있지 않고 countryNames에 있는 경우)
      String newDisplayCode = widget.currentCountryCode;

      if (newDisplayCode.isEmpty || !widget.countryNames.containsKey(newDisplayCode)) {
        // 저장된 설정 확인
        if (savedLanguage != null && widget.countryNames.containsKey(savedLanguage)) {
          newDisplayCode = savedLanguage;
        }
        // 모두 실패하면 첫 번째 국가 사용
        else if (widget.countryNames.isNotEmpty) {
          newDisplayCode = widget.countryNames.keys.first;
        }
        // 최후의 수단으로 'KR' 사용
        else {
          newDisplayCode = 'KR';
        }
      }

      _displayCountryCode = newDisplayCode;
      debugPrint('🌐 AppBar: 표시 언어 설정: $_displayCountryCode');
    });
  }

  @override
  void dispose() {
    // 리스너 해제
    _translationService.removeLanguageChangeListener(_onLanguageChanged);
    super.dispose();
  }

  void _openEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // countryNames가 비어있는지 확인
    if (widget.countryNames.isEmpty) {
      // 빈 앱바 반환 (로딩 중 상태)
      debugPrint('⚠️ countryNames가 비어있습니다. 기본 앱바 표시');
      return AppBar(
        centerTitle: false,
        title: Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
      );
    }

    // 선택된 국가 코드가 countryNames에 없는 경우를 대비한 안전 장치
    if (!widget.countryNames.containsKey(_displayCountryCode)) {
      _displayCountryCode = widget.countryNames.keys.first;
    }

    debugPrint('🏗️ AppBar 빌드 중, 표시 국가: $_displayCountryCode');

    return AppBar(
      centerTitle: false,
      title: Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
      actions: [
        // 언어 아이콘
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Icon(
            Icons.language,
            size: 24,
            color: const Color(0xFF999999),
          ),
        ),

        // 국가 선택 드롭다운
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: IntrinsicWidth(
            child: Container(
              height: 40,
              constraints: const BoxConstraints(minWidth: 100),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              alignment: Alignment.center,
              child: PopupMenuButton<String>(
                initialValue: _displayCountryCode,
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 4,
                constraints: const BoxConstraints(minWidth: 160),
                onSelected: (String newValue) async {
                  debugPrint('🔄 AppBar: 언어 수동 변경: $newValue');

                  // TranslationService를 통해 언어 변경
                  await _translationService.changeLanguage(newValue);

                  // SharedPreferences에 저장
                  await SharedPreferencesService.setLanguage(newValue);

                  // 부모 위젯에 알림
                  widget.onCountryChanged(newValue);

                  // 번역 키 새로고침
                  widget.refreshKeys();

                  // 상태 업데이트
                  setState(() {
                    _displayCountryCode = newValue;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return widget.countryNames.entries.map((entry) {
                    final isLast = entry.key == widget.countryNames.entries.last.key;
                    return PopupMenuItem<String>(
                      value: entry.key,
                      padding: EdgeInsets.zero,
                      height: isLast ? 48 : 49,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: isLast ? 48 : 47,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/country_code/${entry.key}.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Container(
                                height: 1,
                                color: const Color(0xFFE4E4E4),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/country_code/${_displayCountryCode}.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.countryNames[_displayCountryCode] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF999999),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 톱니바퀴 아이콘 추가 - 로그인 상태일 때만 표시
        if (widget.isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.menu, size: 25),
              onPressed: () => _openEndDrawer(context),
              tooltip: '설정',
            ),
          ),
      ],
    );
  }
}