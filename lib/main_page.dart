import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async'; // StreamSubscription 사용을 위해 추가
import 'main.dart';
import 'auth/auth_main_page.dart';
import 'services/shared_preferences_service.dart';
import 'services/translation_service.dart';
import 'compents/bottom_navigation.dart';
import 'compents/appbar.dart';
import 'compents/settings_drawer.dart';
import 'compents/tripfriends_manual/manual_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/register_page.dart';

class MainPage extends StatefulWidget {
  final int? initialIndex;  // 초기 탭 인덱스 파라미터 추가

  const MainPage({super.key, this.initialIndex});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  Map<String, String> countryNames = {};
  Key _authWidgetKey = UniqueKey();
  Key _bottomNavKey = UniqueKey();
  Key _manualKey = UniqueKey(); // 매뉴얼 위젯용 키 추가
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _isCheckingSession = false;
  bool _isProfileComplete = false;
  bool _isRegisterPageActive = false; // 등록 페이지 활성화 상태 추적
  bool _isInitialCheckComplete = false; // 초기 체크 완료 여부 추가
  late TranslationService translationService;
  StreamSubscription? _languageChangeSubscription; // 언어 변경 구독 추가
  String _currentLanguage = ''; // 현재 언어 코드 저장 변수 추가
  bool _wasLoggedOut = true; // 이전 로그아웃 상태 추적

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    translationService = TranslationService();

    // initialIndex가 있으면 해당 탭으로 설정
    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }

    // 현재 언어 코드 초기화
    _currentLanguage = SharedPreferencesService.getLanguage() ?? currentCountryCode;

    // 언어 변경 이벤트 구독
    _languageChangeSubscription = languageChangeController.stream.listen((String newLanguage) {
      if (_currentLanguage != newLanguage) {
        if (mounted) {
          setState(() {
            _currentLanguage = newLanguage;
            debugPrint('🔤 MainPage: 언어 변경 이벤트 수신: $newLanguage');
            loadTranslations(); // 번역 다시 로드
            _refreshKeys(); // UI 갱신
          });
        }
      }
    });

    loadTranslations();
    _checkLoginStatus();

    // authStateChanges 대신 idTokenChanges 사용하여 토큰 갱신 감지
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
    _languageChangeSubscription?.cancel(); // 구독 취소
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkRealLoginStatus();

      // 앱이 다시 활성화될 때 현재 언어 설정 확인 및 업데이트
      _checkLanguageUpdate();
    }
  }

  // 언어 변경 확인 및 업데이트
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
    // 의존성 변경 시 현재 언어 확인
    _checkLanguageUpdate();
  }

  Future<void> _checkRealLoginStatus() async {
    if (_isCheckingSession) return;
    _isCheckingSession = true;

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 등록 페이지 활성화 상태 확인 로직 추가
      _isRegisterPageActive = SharedPreferencesService.getBool('is_registering', defaultValue: false);
      debugPrint('🔍 등록 페이지 활성화 여부: $_isRegisterPageActive');

      bool validAuth = false;
      if (user != null) {
        try {
          // false로 먼저 시도하여 불필요한 네트워크 요청 방지
          await user.getIdToken(false);
          validAuth = true;
        } catch (e) {
          debugPrint('🚫 토큰 확인 실패, 강제 갱신 시도: $e');
          try {
            // 실패한 경우에만 강제 갱신
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

      // 로그인 상태 변경 감지
      final bool justLoggedIn = !_isLoggedIn && realLoggedIn && _wasLoggedOut;

      // mounted 체크 추가
      if (!mounted) return;

      setState(() {
        _isLoggedIn = realLoggedIn;
        _wasLoggedOut = !realLoggedIn; // 현재 로그아웃 상태 업데이트
      });

      SharedPreferencesService.setLoggedIn(realLoggedIn);

      debugPrint('🔐 로그인 상태: $_isLoggedIn (Firebase 기준)');

      if (realLoggedIn) {
        await _checkProfileCompletion();

        // 방금 로그인한 경우 reservation 탭(인덱스 2)으로 이동
        if (justLoggedIn && _isProfileComplete && mounted) {
          setState(() {
            _selectedIndex = 2; // reservation 탭 인덱스
          });
          debugPrint('📍 로그인 성공 - Reservation 탭으로 이동');
        }
      } else {
        // mounted 체크 추가
        if (!mounted) return;

        setState(() {
          _isProfileComplete = false;
          _isInitialCheckComplete = true; // 초기 체크 완료
        });
        debugPrint('🔄 로그아웃 상태 - UI 업데이트');
      }
    } catch (e) {
      debugPrint('로그인 상태 확인 중 오류 발생: $e');
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesService.clearUserSession();

      // mounted 체크 추가
      if (!mounted) return;

      setState(() {
        _isLoggedIn = false;
        _isProfileComplete = false;
        _isInitialCheckComplete = true; // 초기 체크 완료
      });
    } finally {
      _isCheckingSession = false;
    }
  }

  void _checkLoginStatus() async {
    _checkRealLoginStatus();
  }

  Future<void> _checkProfileCompletion() async {
    // 등록 페이지가 활성화된 상태면 중복 리다이렉트 방지
    if (_isRegisterPageActive) {
      debugPrint('🛑 등록 페이지 활성화 상태 - 프로필 검증 건너뜀');

      // 등록 페이지 활성화 상태 해제
      await SharedPreferencesService.setBool('is_registering', false);
      _isRegisterPageActive = false;

      setState(() {
        _isInitialCheckComplete = true;
      });
      // return 제거하여 프로필 완성도 체크 계속 진행
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // mounted 체크 추가
        if (!mounted) return;

        setState(() {
          _isProfileComplete = false;
          _isLoggedIn = false;
          _isInitialCheckComplete = true; // 초기 체크 완료
        });

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AuthMainPageWidget()),
                (route) => false,
          );
        }
        return;
      }

      // 토큰 검증 제거 - 이미 _checkRealLoginStatus에서 검증함
      final docSnapshot = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      debugPrint('👤 Firestore 사용자 정보 조회: 문서 존재 여부: ${docSnapshot.exists}, 데이터: ${docSnapshot.data()}');

      final bool profileExists = docSnapshot.exists &&
          docSnapshot.data() != null &&
          docSnapshot.data()!.containsKey('name');

      // mounted 체크 추가
      if (!mounted) return;

      setState(() {
        _isProfileComplete = profileExists;
        _isInitialCheckComplete = true; // 초기 체크 완료
      });

      // 프로필이 존재하지 않는 경우 RegisterPage로 리다이렉트
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

      // mounted 체크 추가
      if (!mounted) return;

      setState(() {
        _isProfileComplete = false;
        _isLoggedIn = false;
        _isInitialCheckComplete = true; // 초기 체크 완료
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
      // 현재 언어 확인 (SharedPreferences 또는 currentCountryCode)
      String effectiveLanguage = _currentLanguage.isNotEmpty ?
      _currentLanguage :
      (SharedPreferencesService.getLanguage() ?? currentCountryCode);

      debugPrint('📚 MainPage: 국가 목록 로드 중, 사용 언어: $effectiveLanguage');

      final String translationsJson = await rootBundle.loadString('assets/data/country.json');
      final data = json.decode(translationsJson);

      if (mounted) {
        setState(() {
          countryNames = Map.fromEntries(
              (data['countries'] as List).map((country) {
                // 현재 언어 코드로 국가명 가져오기
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

      // currentCountryCode 업데이트 (main.dart의 변수)
      if (currentCountryCode != newCountryCode) {
        currentCountryCode = newCountryCode;

        // 다른 위젯에 변경 알림을 위해 이벤트 발생
        languageChangeController.add(newCountryCode);
      }

      loadTranslations();

      // 언어 변경 시 매뉴얼 위젯 갱신을 위한 키 변경
      _refreshKeys();
    });
  }

  void _refreshKeys() {
    if (!mounted) return;

    setState(() {
      _authWidgetKey = UniqueKey();
      _bottomNavKey = UniqueKey();
      _manualKey = UniqueKey(); // 매뉴얼 위젯 키도 갱신
    });
  }

  void refreshUI() {
    if (!mounted) return;

    setState(() {
      _authWidgetKey = UniqueKey();
      _bottomNavKey = UniqueKey();
      _manualKey = UniqueKey(); // 매뉴얼 위젯 키도 갱신
    });
    _checkRealLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TripFriendsAppBar(
        countryNames: countryNames,
        currentCountryCode: _currentLanguage.isNotEmpty ?
        _currentLanguage :
        currentCountryCode,
        onCountryChanged: _handleCountryChanged,
        refreshKeys: _refreshKeys,
        isLoggedIn: _isLoggedIn,  // 로그인 상태 파라미터 추가
        translationService: translationService,
      ),
      endDrawer: const SettingsDrawer(),
      body: Column(
        children: [
          // 매뉴얼 위젯 - 키를 추가하여 언어 변경 시 재구성
          TripFriendsManual(
            key: _manualKey,
            translationService: translationService,
          ),

          // 메인 컨텐츠
          Expanded(
            child: !_isInitialCheckComplete
                ? Center(
              child: CircularProgressIndicator(), // 로딩 인디케이터
            )
                : _isLoggedIn && _isProfileComplete
                ? CustomBottomNavigation(
              key: _bottomNavKey,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                if (!mounted) return;
                setState(() {
                  _selectedIndex = index;
                });
              },
              mainContent: Container(), // 빈 컨테이너로 대체
            )
                : AuthMainPageWidget(key: _authWidgetKey),
          ),
        ],
      ),
    );
  }
}