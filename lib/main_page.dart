import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'main.dart';
import 'trip_main/trip_main_screen.dart';
import 'auth/auth_main_page.dart';
import 'services/shared_preferences_service.dart';
import 'services/translation_service.dart';
import 'services/version_check_service.dart'; // 버전 체크 서비스 추가
import 'compents/bottom_navigation.dart';
import 'compents/appbar.dart';
import 'compents/settings_drawer.dart';
import 'compents/tripfriends_manual/manual_widget.dart';
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
  Key _manualKey = UniqueKey();
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isCheckingSession = false;
  bool _isProfileComplete = false;
  bool _isRegisterPageActive = false;
  bool _isInitialCheckComplete = false;
  late TranslationService translationService;
  StreamSubscription? _languageChangeSubscription;
  String _currentLanguage = '';
  bool _wasLoggedOut = true;

  @override
  void initState() {
    super.initState();
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
    _checkLoginStatus();

    // 버전 체크 추가
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
    if (_isCheckingSession) return;
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

        // 방금 로그인한 경우 홈 탭(인덱스 0)으로 이동
        if (justLoggedIn && _isProfileComplete && mounted) {
          setState(() {
            _selectedIndex = 0; // 홈 탭 인덱스
          });
          debugPrint('📍 로그인 성공 - 홈 탭으로 이동');
        }
      } else {
        if (!mounted) return;

        setState(() {
          _isProfileComplete = false;
          _isInitialCheckComplete = true;
        });
        debugPrint('🔄 로그아웃 상태 - UI 업데이트');
      }
    } catch (e) {
      debugPrint('로그인 상태 확인 중 오류 발생: $e');
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearUserSession();

      if (!mounted) return;

      setState(() {
        _isLoggedIn = false;
        _isProfileComplete = false;
        _isInitialCheckComplete = true;
      });
    } finally {
      _isCheckingSession = false;
    }
  }

  void _checkLoginStatus() async {
    _checkRealLoginStatus();
  }

  Future<void> _checkProfileCompletion() async {
    if (_isRegisterPageActive) {
      debugPrint('🛑 등록 페이지 활성화 상태 - 프로필 검증 건너뜀');

      await SharedPreferencesService.setBool('is_registering', false);
      _isRegisterPageActive = false;

      setState(() {
        _isInitialCheckComplete = true;
      });
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          _isProfileComplete = false;
          _isLoggedIn = false;
          _isInitialCheckComplete = true;
        });

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
        _isInitialCheckComplete = true;
      });

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
        _isInitialCheckComplete = true;
      });

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
      _manualKey = UniqueKey();
    });
  }

  void refreshUI() {
    if (!mounted) return;

    setState(() {
      _authWidgetKey = UniqueKey();
      _bottomNavKey = UniqueKey();
      _manualKey = UniqueKey();
    });
    _checkRealLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialCheckComplete) {
      return Scaffold(
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

    // 홈 탭(인덱스 0)이 선택된 경우 MainScreen 표시
    if (_selectedIndex == 0) {
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
    }

    // 다른 탭들은 기존대로 BottomNavigation 표시
    return Scaffold(
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
      body: Column(
        children: [
          TripFriendsManual(
            key: _manualKey,
            translationService: translationService,
          ),

          Expanded(
            child: CustomBottomNavigation(
              key: _bottomNavKey,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                if (!mounted) return;
                setState(() {
                  _selectedIndex = index;
                });
              },
              mainContent: Container(),
            ),
          ),
        ],
      ),
    );
  }
}