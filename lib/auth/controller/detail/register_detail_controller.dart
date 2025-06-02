import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // StreamSubscription 사용을 위해 추가
import 'dart:convert';
import '../../register_completion_dialog.dart';
import 'currency_controller.dart';
import 'translation_controller.dart';
import 'referral_controller.dart';
import 'user_location_controller.dart';
import 'point_controller.dart';
import 'auth_controller.dart';
import 'validation_controller.dart';
import 'document_controller.dart';
import 'price_controller.dart';
import '../../../main_page.dart';
import '../../../../main.dart'; // currentCountryCode 가져오기 위해 추가

class RegisterDetailController {
  // 필수 식별자
  final String uid;

  // 자기소개 최소 글자 수 (포인트 지급 기준)
  static const int minimumIntroductionLength = 300;

  // 컨트롤러 인스턴스들
  final TranslationController _translationController = TranslationController();
  final CurrencyController _currencyController = CurrencyController();
  final ReferralController _referralController = ReferralController();
  final UserLocationController _locationController = UserLocationController();
  final PointController _pointController = PointController();
  final AuthController _authController = AuthController();
  final ValidationController _validationController = ValidationController();
  final DocumentController _documentController = DocumentController();
  final PriceController _priceController = PriceController();

  // ValueNotifier들
  final ValueNotifier<bool> isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isValidNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> currencySymbolNotifier = ValueNotifier<String>('₩');
  final ValueNotifier<String> currencyCodeNotifier = ValueNotifier<String>('KRW');
  final ValueNotifier<List<String>> selectedLanguagesNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<String?> referrerCodeErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isCheckingReferrerCode = ValueNotifier<bool>(false);
  final ValueNotifier<String?> referrerCodeSuccessNotifier = ValueNotifier<String?>(null);

  // TextEditingController들
  final TextEditingController referrerCodeController = TextEditingController();
  final TextEditingController introductionController = TextEditingController();

  // 추천인 코드 관련
  String? validatedReferrerCode;
  String? referrerUid;

  // Firebase 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 언어 변경 구독을 저장할 변수 추가
  StreamSubscription? _languageChangeSubscription;

  RegisterDetailController({required this.uid}) {
    // 초기화 작업을 비동기로 처리
    _initialize();

    // 값 변경 상태 업데이트를 위한 리스너 등록
    selectedLanguagesNotifier.addListener(updateValidationState);
    introductionController.addListener(updateValidationState);

    // main.dart의 언어 변경 이벤트 구독 (수정된 부분)
    _languageChangeSubscription = languageChangeController.stream.listen((String newCountryCode) {
      _updateCurrencyForCountryCode(newCountryCode);
      _updatePriceForCountryCode(newCountryCode);
    });
  }

  // 국가 코드에 따라 통화 정보 업데이트 (수정된 메서드)
  void _updateCurrencyForCountryCode(String countryCode) async {
    // ValueNotifier가 dispose되었는지 확인
    try {
      print('언어 변경 감지 - 국가 코드: $countryCode');

      // 통화 정보가 로드되지 않았으면 로드
      if (_currencyController.isEmpty()) {
        await _currencyController.loadCurrencyData();
      }

      // 해당 국가 코드에 맞는 통화 정보 설정
      Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(countryCode);
      if (currencyInfo != null) {
        currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
        currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
        print('언어 변경에 따른 통화 정보 업데이트: $countryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
      }
    } catch (e) {
      // dispose된 후에 호출된 경우 오류를 무시
      print('통화 정보 업데이트 중 오류 (컨트롤러가 이미 dispose됨): $e');
    }
  }

  // 국가 코드에 따라 시간당 요금 업데이트 (수정된 메서드)
  void _updatePriceForCountryCode(String countryCode) {
    try {
      if (_priceController.isEmpty()) {
        // 데이터가 로드되지 않았으면 비동기로 로드 후 가격 업데이트
        _loadPriceDataAndUpdatePrice(countryCode);
      } else {
        // 이미 데이터가 로드되어 있으면 바로 가격 업데이트
        _priceController.getPriceForCountryCode(countryCode);
        print('언어 변경에 따른 시간당 요금 업데이트: $countryCode -> ${_priceController.currentPrice}');
      }
    } catch (e) {
      // dispose된 후에 호출된 경우 오류를 무시
      print('가격 정보 업데이트 중 오류 (컨트롤러가 이미 dispose됨): $e');
    }
  }

  // 가격 데이터 로드 및 업데이트 (비동기)
  Future<void> _loadPriceDataAndUpdatePrice(String countryCode) async {
    try {
      await _priceController.loadPricePerHourData();
      _priceController.getPriceForCountryCode(countryCode);
      print('가격 데이터 로드 후 시간당 요금 업데이트: $countryCode -> ${_priceController.currentPrice}');
    } catch (e) {
      print('가격 데이터 로드 중 오류 (컨트롤러가 이미 dispose됨): $e');
    }
  }

  // 초기화 작업을 비동기로 처리하는 함수
  Future<void> _initialize() async {
    try {
      // 각 컨트롤러 초기화
      await _translationController.loadTranslations();
      await _currencyController.loadCurrencyData();
      await _priceController.loadPricePerHourData();
      await _locationController.loadUserLocation(uid);

      // 이미 저장된 데이터가 있는지 확인
      final userData = await _documentController.loadUserDocument(uid);

      // 유효한 국가 코드 결정 (위치 기반 또는 앱 설정)
      String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
      print('초기화 - 유효 국가 코드: $effectiveCountryCode (위치 코드: ${_locationController.userLocationCode}, 앱 설정: $currentCountryCode)');

      if (userData != null) {
        // pricePerHour 값이 이미 있는 경우
        if (userData['pricePerHour'] != null) {
          _priceController.updatePrice(userData['pricePerHour']);
          print('기존 pricePerHour 값 사용: ${_priceController.currentPrice}');
        }
        // 없는 경우 위치 기반으로 설정
        else {
          _priceController.getPriceForCountryCode(effectiveCountryCode);
        }

        // 기존 통화 심볼 값이 있는 경우
        if (userData['currencySymbol'] != null) {
          currencySymbolNotifier.value = userData['currencySymbol'];
          print('기존 currencySymbol 값 사용: ${currencySymbolNotifier.value}');
        }
        // 없는 경우 국가 코드 기반으로 설정
        else {
          // 통화 정보 설정
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
            print('국가 코드 기반 통화 심볼 설정: $effectiveCountryCode -> ${currencySymbolNotifier.value}');
          }
        }

        // 기존 통화 코드 값이 있는 경우
        if (userData['currencyCode'] != null) {
          currencyCodeNotifier.value = userData['currencyCode'];
          print('기존 currencyCode 값 사용: ${currencyCodeNotifier.value}');
        }
        // 없는 경우 국가 코드 기반으로 설정
        else {
          // 통화 정보 설정
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
            print('국가 코드 기반 통화 코드 설정: $effectiveCountryCode -> ${currencyCodeNotifier.value}');
          }
        }
      } else {
        // 문서가 없는 경우 국가 코드 기반으로 설정
        _priceController.getPriceForCountryCode(effectiveCountryCode);

        // 통화 정보 설정
        Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
        if (currencyInfo != null) {
          currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
          currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
          print('국가 코드 기반 통화 정보 설정: $effectiveCountryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
        } else {
          // 기본값 설정
          currencySymbolNotifier.value = '₩';
          currencyCodeNotifier.value = 'KRW';
          print('통화 정보 설정 실패, 기본값 사용: ₩ (KRW)');
        }
      }
    } catch (e) {
      debugPrint('Error in initialization: $e');
      // 오류 발생 시 기본값 설정
      currencySymbolNotifier.value = '₩';
      currencyCodeNotifier.value = 'KRW';
    }
  }

  bool isValid() {
    return _validationController.isValid(
        selectedLanguages: selectedLanguagesNotifier.value,
        price: _priceController.currentPrice.toString(),
        introduction: introductionController.text
    );
  }

  // 자기소개 글자수가 포인트 지급 조건을 충족하는지 확인
  bool isIntroductionEligibleForPoints() {
    return _validationController.isIntroductionEligibleForPoints(introductionController.text);
  }

  void updateValidationState() {
    isValidNotifier.value = isValid();
  }

  void updateCurrencySymbol(String symbol) {
    _currencyController.updateCurrencySymbol(currencySymbolNotifier, symbol);
  }

  void updateCurrencyCode(String code) {
    _currencyController.updateCurrencyCode(currencyCodeNotifier, code);
  }

  // 위치 정보 변경 시 가격과 통화 정보 업데이트 메서드
  Future<void> updatePriceAndCurrencyForLocation(String location) async {
    try {
      _locationController.updateLocation(location);

      // 유효한 국가 코드 결정 (위치 기반 또는 앱 설정)
      String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
      print('위치 변경 - 유효 국가 코드: $effectiveCountryCode');

      if (_currencyController.isEmpty()) {
        await _currencyController.loadCurrencyData();
      }

      if (_priceController.isEmpty()) {
        await _priceController.loadPricePerHourData();
      }

      // 가격 업데이트
      _priceController.getPriceForCountryCode(effectiveCountryCode);

      // 통화 정보 설정
      Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
      if (currencyInfo != null) {
        currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
        currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
        print('위치 변경에 따른 통화 정보 업데이트: $effectiveCountryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
      }
    } catch (e) {
      print('위치 정보 업데이트 중 오류 (컨트롤러가 이미 dispose됨): $e');
    }
  }

  Future<bool> validateReferrerCode(String code) async {
    if (code.isEmpty) {
      referrerCodeErrorNotifier.value = _translationController.getTranslatedMessage("invalid_referrer_code");
      referrerCodeSuccessNotifier.value = null;
      return false;
    }

    isCheckingReferrerCode.value = true;
    try {
      final result = await _referralController.validateReferrerCode(code);
      if (result.isValid) {
        referrerCodeErrorNotifier.value = null;
        referrerCodeSuccessNotifier.value = _translationController.getTranslatedMessage("referrer_code_matched");
        validatedReferrerCode = code;
        referrerUid = result.referrerUid;
        return true;
      } else {
        referrerCodeErrorNotifier.value = _translationController.getTranslatedMessage("invalid_referrer_code");
        referrerCodeSuccessNotifier.value = null;
        validatedReferrerCode = null;
        referrerUid = null;
        return false;
      }
    } catch (e) {
      referrerCodeErrorNotifier.value = _translationController.getTranslatedMessage("error_checking_code");
      referrerCodeSuccessNotifier.value = null;
      return false;
    } finally {
      isCheckingReferrerCode.value = false;
    }
  }

  Future<void> updateDetails(BuildContext context) async {
    try {
      isSavingNotifier.value = true;
      print('상세 정보 업데이트 시작 - UID: $uid');

      // 사용자 문서 가져오기
      final docRef = _firestore.collection("tripfriends_users").doc(uid);
      final currentDoc = await docRef.get();
      Map<String, dynamic>? userData = currentDoc.data();

      if (userData == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final bool isDetailCompletedBefore = userData['isDetailCompleted'] ?? false;

      // 저장 직전에 현재 국가 코드 확인 및 통화 정보 최종 업데이트
      String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
      print('저장 전 현재 국가 코드 확인: $effectiveCountryCode (앱 설정: $currentCountryCode)');

      // 통화 정보 최종 설정 - 이 부분이 핵심!
      Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
      if (currencyInfo != null) {
        currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
        currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
        print('저장 전 최종 통화 정보 확인: $effectiveCountryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
      }

      // 시간당 요금 최종 확인
      _priceController.getPriceForCountryCode(effectiveCountryCode);

      // 업데이트할 데이터 준비
      final updateData = _prepareUpdateData(await _pointController.getExistingPointValue(uid));

      // 추천인 코드가 있는 경우 추천인 정보 업데이트
      if (validatedReferrerCode != null && referrerUid != null) {
        await _referralController.updateReferrerApproval(uid, referrerUid!, validatedReferrerCode!, updateData);
      }

      // Firestore 문서 업데이트
      await _documentController.updateUserDocument(uid, updateData);
      print('✅ 상세 정보 업데이트 완료');

      // 추천인에게 포인트 지급 처리 (문서 업데이트 후에 실행)
      if (validatedReferrerCode != null && referrerUid != null) {
        await _processReferralPointsReward(userData['name'] ?? '회원');
      }

      // 자기소개 포인트 지급 (회원가입 시)
      if (!isDetailCompletedBefore && isIntroductionEligibleForPoints()) {
        try {
          await _pointController.addProfileCompletionPoints(
              uid,
              currencyCodeNotifier.value,
              introductionController.text.trim().length
          );
          print('✅ 회원가입 시 자기소개 포인트 지급 완료');
        } catch (e) {
          print('⚠️ 자기소개 포인트 지급 중 오류: $e');
        }
      }

      try {
        await _saveSessionAndRefreshToken();
      } catch (e) {
        print('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
      }

      if (context.mounted) {
        // 완료 다이얼로그 표시
        await RegisterCompletionDialog.show(context);

        // 다이얼로그 닫힌 후 메인 페이지로 이동
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false, // 스택의 모든 경로 제거
          );
        }
      }
    } catch (e) {
      print('❌ 상세 정보 업데이트 실패: $e');
      // 에러 메시지 - 스낵바 대신 디버그 프린트로 대체
      print('❌ 저장 실패: $e');
      rethrow;
    } finally {
      isSavingNotifier.value = false;
    }
  }

  // 업데이트 데이터 준비 - 수정된 부분
  Map<String, dynamic> _prepareUpdateData(int existingPoints) {
    return {
      "languages": selectedLanguagesNotifier.value,
      "pricePerHour": _priceController.currentPrice,
      "updatedAt": FieldValue.serverTimestamp(),
      "introduction": introductionController.text.trim(),
      "point": existingPoints, // 기존 포인트 값을 유지
    };
  }

  // 추천인 포인트 처리
  Future<void> _processReferralPointsReward(String currentUserName) async {
    try {
      if (referrerUid != null) {
        // 추천인 정보 가져오기
        final referrerDoc = await _firestore.collection("tripfriends_users").doc(referrerUid).get();
        if (referrerDoc.exists) {
          final referrerData = referrerDoc.data() as Map<String, dynamic>;
          final String referrerCurrencyCode = referrerData['currencyCode'] ?? 'KRW';

          // 추천인(기존 회원)에게만 포인트 지급
          await _pointController.addReferralPoints(
              referrerUid!,
              currentUserName,
              referrerCurrencyCode
          );

          print('✅ 추천인 포인트 지급 완료');
        }
      }
    } catch (e) {
      print('❌ 추천인 포인트 처리 중 오류 발생: $e');
    }
  }

  // 세션 저장 및 토큰 갱신
  Future<void> _saveSessionAndRefreshToken() async {
    try {
      await _authController.saveSessionAndRefreshToken(uid);
      print('✅ 세션 및 토큰 처리 완료');
    } catch (e) {
      // 오류가 발생해도 무시하고 계속 진행
      print('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
    }
  }

  Future<void> loadExistingData() async {
    try {
      final userData = await _documentController.loadUserDocument(uid);

      if (userData != null) {
        selectedLanguagesNotifier.value = List<String>.from(userData['languages'] ?? []);

        // 이미 저장된 가격이 있으면 그것을 사용
        if (userData['pricePerHour'] != null) {
          _priceController.updatePrice(userData['pricePerHour']);
          print('기존 pricePerHour 값 사용: ${_priceController.currentPrice}');
        }
        // 가격 정보가 없는 경우 현재 위치 정보를 사용하여 설정
        else {
          // 위치 정보 업데이트
          if (userData['location'] != null) {
            _locationController.updateLocation(userData['location'] as String);
          }

          // 유효한 국가 코드 결정
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;

          // 위치 기반 가격 설정
          _priceController.getPriceForCountryCode(effectiveCountryCode);
        }

        // 통화 심볼 로드
        if (userData['currencySymbol'] != null) {
          currencySymbolNotifier.value = userData['currencySymbol'];
        } else {
          // 유효한 국가 코드 결정
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;

          // 통화 정보 설정
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
          }
        }

        // 통화 코드 로드
        if (userData['currencyCode'] != null) {
          currencyCodeNotifier.value = userData['currencyCode'];
        } else {
          // 유효한 국가 코드 결정
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;

          // 통화 정보 설정
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
          }
        }

        introductionController.text = userData['introduction'] ?? '';
      }
    } catch (e) {
      print('❌ 기존 데이터 로드 실패: $e');
    }
  }

  void dispose() {
    // 언어 변경 구독 취소 추가
    _languageChangeSubscription?.cancel();

    // Bool Notifiers
    isSavingNotifier.dispose();
    isValidNotifier.dispose();
    isCheckingReferrerCode.dispose();

    // String Notifiers
    currencySymbolNotifier.dispose();
    currencyCodeNotifier.dispose();
    referrerCodeErrorNotifier.dispose();

    // List Notifiers
    selectedLanguagesNotifier.dispose();

    // Controller
    referrerCodeController.dispose();
    introductionController.dispose();

    // 레퍼럴 코드 확인
    referrerCodeSuccessNotifier.dispose();
  }
}