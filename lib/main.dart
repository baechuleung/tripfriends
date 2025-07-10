// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'services/shared_preferences_service.dart';
import 'services/fcm_service/fcm_service.dart';
import 'services/fcm_service/handlers/message_handler.dart';
import 'dart:async';
import 'routes/app_routes.dart';
import 'cache_manager.dart';

export 'main.dart' show currentCountryCode, isLanguageChanging;

// 초기 기본값을 'KR'로 설정
String currentCountryCode = 'KR';

// 언어 변경 중인지 표시하는 전역 변수
bool isLanguageChanging = false;

// 언어 변경 이벤트를 구독할 수 있는 스트림 컨트롤러 - 싱글톤 패턴 적용
class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  final StreamController<String> _languageChangeController = StreamController<String>.broadcast();
  final StreamController<bool> _loadingStateController = StreamController<bool>.broadcast();

  Stream<String> get languageChanges => _languageChangeController.stream;
  Stream<bool> get loadingStates => _loadingStateController.stream;

  void updateLanguage(String language) {
    if (!_languageChangeController.isClosed) {
      _languageChangeController.add(language);
    }
  }

  void updateLoadingState(bool isLoading) {
    if (!_loadingStateController.isClosed) {
      _loadingStateController.add(isLoading);
    }
  }

  void dispose() {
    _languageChangeController.close();
    _loadingStateController.close();
  }
}

final languageManager = LanguageManager();
// 기존 전역 변수 대체
final languageChangeController = languageManager._languageChangeController;
final loadingStateController = languageManager._loadingStateController;

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

  // 캐시 매니저 초기화
  AggressiveCacheManager.initialize();
  await AggressiveCacheManager.clearAllCaches();

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
    'KR', 'VN', 'JP', 'TH', 'PH', 'MY', 'EN'
  ];

  // 언어 코드를 국가 코드로 매핑
  const Map<String, String> LANGUAGE_TO_COUNTRY = {
    'KO': 'KR',
    'VI': 'VN',
    'JA': 'JP',
    'TH': 'TH',
    'TL': 'PH',
    'FIL': 'PH',
    'MS': 'MY',
    'EN': 'EN',
  };

  // 언어 설정 결정
  if (LANGUAGE_TO_COUNTRY.containsKey(deviceLanguage)) {
    currentCountryCode = LANGUAGE_TO_COUNTRY[deviceLanguage]!;
  } else if (SUPPORTED_COUNTRY_CODES.contains(deviceCountry)) {
    currentCountryCode = deviceCountry;
  } else {
    currentCountryCode = 'KR';
  }

  await SharedPreferencesService.setLanguage(currentCountryCode);
  debugPrint('📱 언어 설정 적용: $currentCountryCode');

  // Firebase 초기화
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Firebase Realtime Database URL 설정
  FirebaseDatabase.instance.databaseURL =
  'https://tripjoy-d309f-default-rtdb.asia-southeast1.firebasedatabase.app/';

  // 세션 유효성 검사
  await SharedPreferencesService.validateAndCleanSession();

  // FCM 서비스 초기화
  await FCMService.initialize();

  // FCM 토큰 갱신 리스너 설정
  FCMService.setupTokenRefresh((String newToken) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FCMService.updateTokenInDatabase(currentUser.uid, newToken);
      await SharedPreferencesService.setFCMToken(newToken);
    }
  });

  // 로그인 상태 확인
  bool isLoggedIn = SharedPreferencesService.isLoggedIn();
  debugPrint('👤 로그인 상태 확인: ${isLoggedIn ? '로그인됨' : '로그인되지 않음'}');

  if (isLoggedIn && FirebaseAuth.instance.currentUser == null) {
    String? uid = SharedPreferencesService.getUserUid();
    if (uid == null || uid.isEmpty) {
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isLoading = false;
  Timer? _memoryCheckTimer;
  StreamSubscription? _loadingSubscription;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 스트림 구독
    _loadingSubscription = languageManager.loadingStates.listen((bool loading) {
      if (mounted) {
        setState(() {
          _isLoading = loading;
          isLanguageChanging = loading;
        });
      }
    });

    // 인증 리스너 설정 - 한 번만
    _setupAuthListener();

    // 메모리 체크 타이머 - 3분으로 늘림
    _memoryCheckTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      _checkMemoryPressure();
    });
  }

  void _setupAuthListener() {
    // 기존 구독 취소
    _authSubscription?.cancel();

    // 새 구독 생성
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        FCMService.onUserLogin(user.uid);
      } else {
        String? uid = SharedPreferencesService.getUserUid();
        if (uid != null) {
          FCMService.onUserLogout(uid);
        }
      }
    });
  }

  void _checkMemoryPressure() {
    final imageCache = PaintingBinding.instance.imageCache;
    final currentSize = imageCache.currentSizeBytes;
    final maxSize = imageCache.maximumSizeBytes;

    if (currentSize > maxSize * 0.8) {
      debugPrint('⚠️ 메모리 압박 감지: ${currentSize ~/ 1024 ~/ 1024}MB / ${maxSize ~/ 1024 ~/ 1024}MB');
      AggressiveCacheManager.emergencyClear();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        debugPrint('📱 앱 백그라운드 전환 - 캐시 정리');
        AggressiveCacheManager.clearAllCaches();
        break;
      case AppLifecycleState.resumed:
        debugPrint('📱 앱 포그라운드 복귀');
        break;
      case AppLifecycleState.inactive:
        AggressiveCacheManager.emergencyClear();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _memoryCheckTimer?.cancel();
    _loadingSubscription?.cancel();
    _authSubscription?.cancel();
    AggressiveCacheManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainPage = const MainPage();

    return MaterialApp(
      navigatorKey: navigatorKey,
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        cardTheme: const CardThemeData(
          clipBehavior: Clip.none,
        ),
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
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.getRoutes(mainPage),
      home: Stack(
        children: [mainPage],
      ),
    );
  }
}

// 앱 종료 시 정리
void disposeLanguageChangeController() {
  languageManager.dispose();
}