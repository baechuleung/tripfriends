import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'main.dart';
import 'trip_main/trip_main_screen.dart';
import 'job_main/job_main_screen.dart';
import 'talk_main/talk_main_screen.dart';
import 'info_main/info_main_screen.dart';
import 'auth/auth_main_page.dart';
import 'services/shared_preferences_service.dart';
import 'services/translation_service.dart';
import 'services/version_check_service.dart';
import 'compents/bottom_navigation.dart';
import 'compents/appbar.dart';
import 'compents/settings_drawer.dart';
import 'compents/top_tab_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/register_page.dart';

class MainPage extends StatefulWidget {
  final int? initialIndex;

  const MainPage({super.key, this.initialIndex});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  // 상태 변수들
  Map<String, String> countryNames = {};
  Key _authWidgetKey = UniqueKey();
  Key _bottomNavKey = UniqueKey();
  int _selectedIndex = 0;
  int _selectedTabIndex = 0;
  bool _isLoggedIn = false;
  bool _isCheckingSession = false;
  bool _isProfileComplete = false;
  bool _isInitialCheckComplete = false;
  late TranslationService translationService;
  String _currentLanguage = '';

  // 스트림 구독 관리
  StreamSubscription? _languageChangeSubscription;
  StreamSubscription? _authStateSubscription;
  Timer? _initTimeoutTimer;

  // 캐시된 국가 데이터
  static Map<String, dynamic>? _cachedCountryData;
  static String? _cachedDataLanguage;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 MainPage initState 시작');
    WidgetsBinding.instance.addObserver(this);
    translationService = TranslationService();

    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }

    _currentLanguage = SharedPreferencesService.getLanguage() ?? currentCountryCode;

    // 언어 변경 리스너 - 중복 방지
    _languageChangeSubscription = languageChangeController.stream.listen((String newLanguage) {
      if (_currentLanguage != newLanguage && mounted) {
        setState(() {
          _currentLanguage = newLanguage;
          debugPrint('🔤 MainPage: 언어 변경 이벤트 수신: $newLanguage');
        });
        loadTranslations();
      }
    });

    // 초기 번역 로드
    loadTranslations();

    // 초기화 타임아웃 - 3초로 단축
    _initTimeoutTimer = Timer(const Duration(seconds: 3), () {
      if (!_isInitialCheckComplete && mounted) {
        debugPrint('⏰ 초기화 타임아웃 - 강제로 완료 처리');
        setState(() {
          _isInitialCheckComplete = true;
          _isLoggedIn = false;
          _isProfileComplete = false;
        });
      }
    });

    // 인증 상태 체크 - 한 번만
    _initializeAuthCheck();

    // 버전 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        VersionCheckService.checkVersion(context);
      }
    });
  }

  // 인증 초기화 - 중복 방지
  void _initializeAuthCheck() {
    // 기존 구독 취소
    _authStateSubscription?.cancel();

    // 즉시 현재 상태 체크
    _checkCurrentAuthState();

    // 향후 변경사항 리스닝
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        debugPrint('🔑 인증 상태 변경 감지');
        _handleAuthStateChange(user);
      }
    });
  }

  // 현재 인증 상태 체크 - 단순화
  Future<void> _checkCurrentAuthState() async {
    if (_isCheckingSession) return;
    _isCheckingSession = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      await _handleAuthStateChange(user);
    } finally {
      _isCheckingSession = false;
    }
  }

  // 인증 상태 변경 핸들러 - 통합
  Future<void> _handleAuthStateChange(User? user) async {
    if (!mounted) return;

    final isRegistering = SharedPreferencesService.getBool('is_registering', defaultValue: false);

    if (isRegistering) {
      await SharedPreferencesService.setBool('is_registering', false);
      setState(() {
        _isInitialCheckComplete = true;
      });
      return;
    }

    bool isValid = false;
    if (user != null) {
      try {
        await user.getIdToken(false);
        isValid = true;
      } catch (e) {
        debugPrint('🚫 토큰 검증 실패: $e');
        await FirebaseAuth.instance.signOut();
        await SharedPreferencesService.clearUserSession();
      }
    }

    setState(() {
      _isLoggedIn = isValid;
    });

    if (isValid) {
      await _checkProfileCompletion(user!);
    } else {
      setState(() {
        _isProfileComplete = false;
        _isInitialCheckComplete = true;
      });
    }
  }

  // 프로필 완성도 체크 - 최적화
  Future<void> _checkProfileCompletion(User user) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      final bool profileExists = docSnapshot.exists &&
          docSnapshot.data() != null &&
          docSnapshot.data()!.containsKey('name');

      if (!mounted) return;

      setState(() {
        _isProfileComplete = profileExists;
        _isInitialCheckComplete = true;
      });

      if (!profileExists && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(uid: user.uid),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('프로필 확인 중 오류: $e');
      if (mounted) {
        setState(() {
          _isProfileComplete = false;
          _isLoggedIn = false;
          _isInitialCheckComplete = true;
        });
      }
    }
  }

  // 번역 로드 - 캐싱 적용
  Future<void> loadTranslations() async {
    try {
      String effectiveLanguage = _currentLanguage.isNotEmpty
          ? _currentLanguage
          : (SharedPreferencesService.getLanguage() ?? currentCountryCode);

      // 캐시된 데이터가 있고 언어가 같으면 재사용
      if (_cachedCountryData != null && _cachedDataLanguage == effectiveLanguage) {
        if (mounted) {
          setState(() {
            countryNames = Map.fromEntries(
                (_cachedCountryData!['countries'] as List).map((country) {
                  String countryName = country['names'][effectiveLanguage] ??
                      country['names']['KR'] as String;
                  return MapEntry(country['code'] as String, countryName);
                })
            );
          });
        }
        return;
      }

      // 캐시에 없으면 로드
      final String translationsJson = await rootBundle.loadString('assets/data/country.json');
      final data = json.decode(translationsJson);

      // 캐시에 저장
      _cachedCountryData = data;
      _cachedDataLanguage = effectiveLanguage;

      if (mounted) {
        setState(() {
          countryNames = Map.fromEntries(
              (data['countries'] as List).map((country) {
                String countryName = country['names'][effectiveLanguage] ??
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

  @override
  void dispose() {
    _initTimeoutTimer?.cancel();
    _languageChangeSubscription?.cancel();
    _authStateSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // 앱이 포그라운드로 돌아올 때만 체크
      _checkLanguageUpdate();
    }
  }

  void _checkLanguageUpdate() {
    String? savedLanguage = SharedPreferencesService.getLanguage();
    if (savedLanguage != null && savedLanguage != _currentLanguage && mounted) {
      setState(() {
        _currentLanguage = savedLanguage;
      });
      loadTranslations();
    }
  }

  void _handleCountryChanged(String newCountryCode) {
    if (!mounted || _currentLanguage == newCountryCode) return;

    setState(() {
      _currentLanguage = newCountryCode;
    });

    if (currentCountryCode != newCountryCode) {
      currentCountryCode = newCountryCode;
      languageChangeController.add(newCountryCode);
    }

    loadTranslations();
  }

  void _refreshKeys() {
    if (!mounted) return;
    setState(() {
      _authWidgetKey = UniqueKey();
      _bottomNavKey = UniqueKey();
    });
  }

  void refreshUI() {
    if (!mounted) return;
    _refreshKeys();
    _checkCurrentAuthState();
  }

  Widget _getTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return MainScreen(
          countryNames: countryNames,
          currentLanguage: _currentLanguage,
          onCountryChanged: _handleCountryChanged,
          refreshKeys: _refreshKeys,
          translationService: translationService,
          onNavigateToTab: (index) {
            if (mounted) {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
        );
      case 1:
        return const JobMainScreen();
      case 2:
        return const TalkMainScreen();
      case 3:
        return const InfoMainScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialCheckComplete) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn || !_isProfileComplete) {
      return Scaffold(
        body: AuthMainPageWidget(key: _authWidgetKey),
      );
    }

    // 홈 탭이 선택된 경우
    if (_selectedIndex == 0) {
      if (_selectedTabIndex == 0) {
        return Scaffold(
          appBar: TripFriendsAppBar(
            countryNames: countryNames,
            currentCountryCode: _currentLanguage,
            onCountryChanged: _handleCountryChanged,
            refreshKeys: _refreshKeys,
            isLoggedIn: _isLoggedIn,
            translationService: translationService,
          ),
          endDrawer: const SettingsDrawer(),
          body: Column(
            children: [
              const SizedBox(height: 10),
              TopTabBar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                language: _currentLanguage,
              ),
              Expanded(
                child: MainScreen(
                  countryNames: countryNames,
                  currentLanguage: _currentLanguage,
                  onCountryChanged: _handleCountryChanged,
                  refreshKeys: _refreshKeys,
                  translationService: translationService,
                  onNavigateToTab: (index) {
                    if (mounted) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          appBar: TripFriendsAppBar(
            countryNames: countryNames,
            currentCountryCode: _currentLanguage,
            onCountryChanged: _handleCountryChanged,
            refreshKeys: _refreshKeys,
            isLoggedIn: _isLoggedIn,
            translationService: translationService,
          ),
          endDrawer: const SettingsDrawer(),
          body: Column(
            children: [
              const SizedBox(height: 10),
              TopTabBar(
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                language: _currentLanguage,
              ),
              Expanded(
                child: _getTabContent(),
              ),
            ],
          ),
        );
      }
    }

    return CustomBottomNavigation(
      key: _bottomNavKey,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        if (mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      mainContent: Container(),
    );
  }
}