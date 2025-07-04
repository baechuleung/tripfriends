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
  Map<String, String> countryNames = {};
  Key _authWidgetKey = UniqueKey();
  Key _bottomNavKey = UniqueKey();
  int _selectedIndex = 0;
  int _selectedTabIndex = 0;
  bool _isLoggedIn = false;
  bool _isCheckingSession = false;
  bool _isProfileComplete = false;
  bool _isRegisterPageActive = false;
  bool _isInitialCheckComplete = false;
  late TranslationService translationService;
  StreamSubscription? _languageChangeSubscription;
  String _currentLanguage = '';
  bool _wasLoggedOut = true;
  Timer? _initTimeoutTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 MainPage initState 시작');
    WidgetsBinding.instance.addObserver(this);
    translationService = TranslationService();

    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }

    _currentLanguage =
        SharedPreferencesService.getLanguage() ?? currentCountryCode;

    _languageChangeSubscription =
        languageChangeController.stream.listen((String newLanguage) {
          if (_currentLanguage != newLanguage) {
            if (mounted) {
              setState(() {
                _currentLanguage = newLanguage;
                debugPrint('🔤 MainPage: 언어 변경 이벤트 수신: $newLanguage');
                loadTranslations();
                _refreshKeys();
              });
            }
          }
        });

    loadTranslations();

    // 초기화 타임아웃 설정 - 5초 후에도 완료되지 않으면 강제로 완료 처리
    _initTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (!_isInitialCheckComplete && mounted) {
        debugPrint('⏰ 초기화 타임아웃 - 강제로 완료 처리');
        setState(() {
          _isInitialCheckComplete = true;
          _isLoggedIn = false;
          _isProfileComplete = false;
        });
      }
    });

    _checkLoginStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        VersionCheckService.checkVersion(context);
      }
    });

    FirebaseAuth.instance.idTokenChanges().listen((User? user) {
      if (mounted) {
        debugPrint('🔑 토큰 상태 변경 감지');
        _checkRealLoginStatus();
      }
    });
  }

  @override
  void dispose() {
    _initTimeoutTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _languageChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkRealLoginStatus();
      _checkLanguageUpdate();
    }
  }

  Future<void> _checkLanguageUpdate() async {
    String? savedLanguage = SharedPreferencesService.getLanguage();
    if (savedLanguage != null && savedLanguage != _currentLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = savedLanguage;
          debugPrint('🔄 MainPage: 앱 재개 시 언어 변경 감지: $_currentLanguage');
          loadTranslations();
          _refreshKeys();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLanguageUpdate();
  }

  Future<void> _checkRealLoginStatus() async {
    debugPrint('🔍 _checkRealLoginStatus 시작');
    if (_isCheckingSession) {
      debugPrint('⚠️ 이미 세션 체크 중 - 건너뜀');
      return;
    }
    _isCheckingSession = true;

    try {
      final user = FirebaseAuth.instance.currentUser;

      _isRegisterPageActive = SharedPreferencesService.getBool(
          'is_registering', defaultValue: false);
      debugPrint('🔍 등록 페이지 활성화 여부: $_isRegisterPageActive');

      bool validAuth = false;
      if (user != null) {
        try {
          await user.getIdToken(false);
          validAuth = true;
        } catch (e) {
          debugPrint('🚫 토큰 확인 실패, 강제 갱신 시도: $e');
          try {
            await user.getIdToken(true);
            validAuth = true;
          } catch (e2) {
            debugPrint('🚫 토큰 강제 갱신도 실패: $e2');
            await FirebaseAuth.instance.signOut();
            await SharedPreferencesService.clearUserSession();
            validAuth = false;
          }
        }
      }

      final bool realLoggedIn = user != null && validAuth;

      final bool justLoggedIn = !_isLoggedIn && realLoggedIn && _wasLoggedOut;

      if (!mounted) return;

      setState(() {
        _isLoggedIn = realLoggedIn;
        _wasLoggedOut = !realLoggedIn;
      });

      SharedPreferencesService.setLoggedIn(realLoggedIn);

      debugPrint('🔐 로그인 상태: $_isLoggedIn (Firebase 기준)');

      if (realLoggedIn) {
        await _checkProfileCompletion();

        if (justLoggedIn && _isProfileComplete && mounted) {
          setState(() {
            _selectedIndex = 0;
          });
          debugPrint('📍 로그인 성공 - 홈 탭으로 이동');
        }
      } else {
        if (!mounted) return;

        setState(() {
          _isProfileComplete = false;
          _isInitialCheckComplete = true;  // 로그아웃 상태에서도 반드시 설정
        });
        debugPrint('🔄 로그아웃 상태 - UI 업데이트, 초기화 완료');
      }
    } catch (e) {
      debugPrint('로그인 상태 확인 중 오류 발생: $e');
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearUserSession();

      if (!mounted) return;

      setState(() {
        _isLoggedIn = false;
        _isProfileComplete = false;
        _isInitialCheckComplete = true;  // 오류 상태에서도 반드시 설정
      });
      debugPrint('❌ 오류 발생 - 초기화 완료 처리');
    } finally {
      _isCheckingSession = false;
      debugPrint('🏁 _checkRealLoginStatus 완료');
    }
  }

  void _checkLoginStatus() async {
    debugPrint('🔍 _checkLoginStatus 호출');
    _checkRealLoginStatus();
  }

  Future<void> _checkProfileCompletion() async {
    debugPrint('👤 _checkProfileCompletion 시작');
    if (_isRegisterPageActive) {
      debugPrint('🛑 등록 페이지 활성화 상태 - 프로필 검증 건너뜀');

      await SharedPreferencesService.setBool('is_registering', false);
      _isRegisterPageActive = false;

      setState(() {
        _isInitialCheckComplete = true;  // 등록 페이지 활성화 상태에서도 설정
      });
      return;  // early return 추가
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isProfileComplete = false;
          _isLoggedIn = false;
          _isInitialCheckComplete = true;  // user null 상태에서도 설정
        });
        debugPrint('⚠️ user null - 초기화 완료 처리');

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AuthMainPageWidget()),
                (route) => false,
          );
        }
        return;
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      debugPrint('👤 Firestore 사용자 정보 조회: 문서 존재 여부: ${docSnapshot
          .exists}, 데이터: ${docSnapshot.data()}');

      final bool profileExists = docSnapshot.exists &&
          docSnapshot.data() != null &&
          docSnapshot.data()!.containsKey('name');

      if (!mounted) return;

      setState(() {
        _isProfileComplete = profileExists;
        _isInitialCheckComplete = true;  // 프로필 체크 완료 후 항상 설정
      });
      debugPrint('✅ 프로필 체크 완료 - 초기화 완료 처리');

      if (!profileExists) {
        debugPrint('⚠️ 사용자 프로필이 완료되지 않음 - RegisterPage로 이동');

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(uid: user.uid),
            ),
                (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('프로필 확인 중 오류 발생: $e');
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearUserSession();

      if (!mounted) return;

      setState(() {
        _isProfileComplete = false;
        _isLoggedIn = false;
        _isInitialCheckComplete = true;  // 오류 상태에서도 설정
      });
      debugPrint('❌ 프로필 체크 오류 - 초기화 완료 처리');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthMainPageWidget()),
              (route) => false,
        );
      }
    }
  }

  Future<void> loadTranslations() async {
    try {
      String effectiveLanguage = _currentLanguage.isNotEmpty ?
      _currentLanguage :
      (SharedPreferencesService.getLanguage() ?? currentCountryCode);

      debugPrint('📚 MainPage: 국가 목록 로드 중, 사용 언어: $effectiveLanguage');

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

          debugPrint('✅ MainPage: 국가 목록 로드 완료, 항목 수: ${countryNames.length}');
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
      debugPrint('🔄 MainPage: 앱바에서 언어 변경: $newCountryCode');

      if (currentCountryCode != newCountryCode) {
        currentCountryCode = newCountryCode;
        languageChangeController.add(newCountryCode);
      }

      loadTranslations();
      _refreshKeys();
    });
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

    setState(() {
      _authWidgetKey = UniqueKey();
      _bottomNavKey = UniqueKey();
    });
    _checkRealLoginStatus();
  }

  Widget _getTabContent() {
    switch (_selectedTabIndex) {
      case 0: // travel
        return MainScreen(
          countryNames: countryNames,
          currentLanguage: _currentLanguage,
          onCountryChanged: _handleCountryChanged,
          refreshKeys: _refreshKeys,
          translationService: translationService,
          onNavigateToTab: (index) {
            if (!mounted) return;
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 1: // job search
        return const JobMainScreen();
      case 2: // Talk
        return const TalkMainScreen();
      case 3: // information
        return const InfoMainScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ MainPage build - 초기화 완료: $_isInitialCheckComplete');

    if (!_isInitialCheckComplete) {
      debugPrint('⏳ 스플래시 화면 표시');
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn || !_isProfileComplete) {
      debugPrint('🔓 로그인 페이지 표시');
      return Scaffold(
        body: AuthMainPageWidget(key: _authWidgetKey),
      );
    }

    // 홈 탭(인덱스 0)이 선택된 경우 기존 로직 유지
    if (_selectedIndex == 0) {
      // travel 탭이 선택된 경우에만 앱바와 탭바 표시
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
              const SizedBox(height: 10), // 앱바와 탭바 사이 간격
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
                    if (!mounted) return;
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        // 다른 상단 탭들 (job search, Talk, information)
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
              const SizedBox(height: 10), // 앱바와 탭바 사이 간격
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

    // travel 탭의 하위 페이지들은 탭바와 앱바 없이 CustomBottomNavigation만 표시
    return CustomBottomNavigation(
      key: _bottomNavKey,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        if (!mounted) return;
        setState(() {
          _selectedIndex = index;
        });
      },
      mainContent: Container(),
    );
  }
}