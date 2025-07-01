// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NoAnimationPageTransitionBuilder 오류 수정을 위해 추가
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database 추가
import 'services/shared_preferences_service.dart';
import 'services/fcm_service/fcm_service.dart'; // FCM 서비스 임포트
import 'services/fcm_service/handlers/message_handler.dart'; // navigatorKey 임포트
import 'dart:async';
import 'routes/app_routes.dart'; // 간단한 라우터 파일 임포트

export 'main.dart' show currentCountryCode, isLanguageChanging;

// 초기 기본값을 'KR'로 설정
String currentCountryCode = 'KR';

// 언어 변경 중인지 표시하는 전역 변수 (로딩 스피너에 사용)
bool isLanguageChanging = false;

// 언어 변경 이벤트를 구독할 수 있는 스트림 컨트롤러 추가
final StreamController<String> languageChangeController =
StreamController<String>.broadcast();

// 로딩 상태 변경 이벤트 스트림 컨트롤러 추가
final StreamController<bool> loadingStateController =
StreamController<bool>.broadcast();

// 애니메이션 없는 페이지 전환을 위한 클래스
class NoAnimationPageTransitionBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // SharedPreferences 초기화
  await SharedPreferencesService.initialize();

  // 기기 로케일 정보 가져오기
  final Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  String deviceLanguage = deviceLocale.languageCode.toUpperCase();
  String deviceCountry = deviceLocale.countryCode?.toUpperCase() ?? '';

  debugPrint('📱 기기 언어: $deviceLanguage, 국가: $deviceCountry');

  // 지원하는 국가 코드 목록
  const List<String> SUPPORTED_COUNTRY_CODES = [
    'KR',
    'VN',
    'JP',
    'TH',
    'PH',
    'MY',
    'EN'
  ];

  // 언어 코드를 국가 코드로 매핑
  const Map<String, String> LANGUAGE_TO_COUNTRY = {
    'KO': 'KR', // 한국어 -> 한국
    'VI': 'VN', // 베트남어 -> 베트남
    'JA': 'JP', // 일본어 -> 일본
    'TH': 'TH', // 태국어 -> 태국
    'TL': 'PH', // 타갈로그어 -> 필리핀
    'FIL': 'PH', // 필리핀어 -> 필리핀
    'MS': 'MY', // 말레이어 -> 말레이시아
    'EN': 'EN', // 영어
  };

  // 1. 먼저 언어 코드로 국가 확인
  if (LANGUAGE_TO_COUNTRY.containsKey(deviceLanguage)) {
    currentCountryCode = LANGUAGE_TO_COUNTRY[deviceLanguage]!;
  }
  // 2. 언어 매핑이 없으면 국가 코드 확인
  else if (SUPPORTED_COUNTRY_CODES.contains(deviceCountry)) {
    currentCountryCode = deviceCountry;
  }
  // 3. 둘 다 없으면 기본값 'KR' 사용
  else {
    currentCountryCode = 'KR';
  }

  // 언어 설정 저장
  await SharedPreferencesService.setLanguage(currentCountryCode);
  debugPrint('📱 언어 설정 적용: $currentCountryCode');

  // Firebase 초기화 - 반드시 세션 검증 전에 실행
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Firebase Realtime Database URL 설정
  FirebaseDatabase.instance.databaseURL =
  'https://tripjoy-d309f-default-rtdb.asia-southeast1.firebasedatabase.app/';

  // Firebase 초기화 후에 세션 유효성 검사 실행
  await SharedPreferencesService.validateAndCleanSession();

  // FCM 서비스 초기화 - 기존 setupNotifications 대신 전체 초기화 사용
  await FCMService.initialize();

  // FCM 토큰 갱신 리스너 설정
  FCMService.setupTokenRefresh((String newToken) async {
    // 현재 로그인한 사용자가 있는 경우 Firestore에 토큰 업데이트
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FCMService.updateTokenInDatabase(currentUser.uid, newToken);
      debugPrint('✅ Firestore의 FCM 토큰 업데이트 완료');

      // 로컬 저장소에도 업데이트
      await SharedPreferencesService.setFCMToken(newToken);
    }
  });

  // 로그인 상태 확인
  bool isLoggedIn = SharedPreferencesService.isLoggedIn();
  debugPrint('👤 로그인 상태 확인: ${isLoggedIn ? '로그인됨' : '로그인되지 않음'}');

  // 로그인 상태이지만 Firebase Auth가 null인 경우, 자동 로그인 시도 (전화번호 관련 코드 제거)
  if (isLoggedIn && FirebaseAuth.instance.currentUser == null) {
    // 저장된 UID 가져오기
    String? uid = SharedPreferencesService.getUserUid();

    if (uid != null && uid.isNotEmpty) {
      debugPrint('✅ 세션 정보 있음 - 로그인 상태 유지');
      // 세션 정보만 확인하고 유지
      // Firebase Auth는 자체적으로 세션 복구 시도
    } else {
      debugPrint('❌ 세션 정보 없음, 로그인 필요');
      await SharedPreferencesService.clearUserSession();
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 언어 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListeners();
    // 버전 체크를 여기서 제거

    // 로딩 상태 변경 이벤트 구독
    loadingStateController.stream.listen((bool loading) {
      if (mounted) {
        setState(() {
          _isLoading = loading;
          isLanguageChanging = loading;
        });
      }
    });
  }

  void _setupAuthListeners() {
    // Firebase 인증 상태 변화 감지
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // 로그인 시 FCM 토큰 업데이트
        FCMService.onUserLogin(user.uid);
      } else {
        // 로그아웃 상태일 때 처리
        String? uid = SharedPreferencesService.getUserUid();
        if (uid != null) {
          FCMService.onUserLogout(uid);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 국가 코드 변경 및 알림
  Future<void> _updateCountryCode(String newCountryCode) async {
    if (currentCountryCode != newCountryCode) {
      // 로딩 시작
      loadingStateController.add(true);

      await SharedPreferencesService.setLanguage(newCountryCode);
      if (mounted) {
        setState(() {
          currentCountryCode = newCountryCode;
          debugPrint('🔄 언어 설정 업데이트: $currentCountryCode');

          // 언어 변경 이벤트 발생
          languageChangeController.add(newCountryCode);
        });
      }

      // 로딩 완료 (잠시 지연 후 로딩 종료 - UI가 업데이트될 시간 제공)
      await Future.delayed(const Duration(milliseconds: 500));
      loadingStateController.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MainPage 인스턴스 생성
    final mainPage = const MainPage();

    return MaterialApp(
      navigatorKey: navigatorKey, // 전역 네비게이터 키 설정
      title: 'tripfriends',
      theme: ThemeData(
        fontFamily: 'SpoqaHanSansNeo',
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          background: Colors.white,
          surface: Colors.white,
          surfaceTint: Colors.transparent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        // 모든 터치/클릭 효과 완전히 제거
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        cardTheme: CardThemeData(
          clipBehavior: Clip.none, // 카드에서 잉크 효과 제거
        ),
        // 버튼 스타일 기본값 설정
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
          ),
        ),
        // 리스트 타일 클릭 색상 변화 제거
        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
        ),
      ),
      debugShowCheckedModeBanner: false,

      // 간단한 라우터 설정 - 메인 페이지 경로만 추가
      routes: AppRoutes.getRoutes(mainPage),

      // 기본 홈 화면 설정
      home: Stack(
        children: [
          mainPage, // 기본 메인 페이지
        ],
      ),
    );
  }
}

// 앱 종료 시 StreamController 정리 함수 추가
void disposeLanguageChangeController() {
  languageChangeController.close();
  loadingStateController.close();
}