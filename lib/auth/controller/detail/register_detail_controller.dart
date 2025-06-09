import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import '../../register_completion_dialog.dart';
import 'currency_controller.dart';
import 'translation_controller.dart';
import 'referral_controller.dart';
import 'user_location_controller.dart';
import 'auth_controller.dart';
import 'validation_controller.dart';
import 'document_controller.dart';
import 'price_controller.dart';
import '../../../main_page.dart';
import '../../../../main.dart';

class RegisterDetailController {
  // 필수 식별자
  final String uid;

  // 컨트롤러 인스턴스들
  final TranslationController _translationController = TranslationController();
  final CurrencyController _currencyController = CurrencyController();
  final ReferralController _referralController = ReferralController();
  final UserLocationController _locationController = UserLocationController();
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

    // main.dart의 언어 변경 이벤트 구독
    _languageChangeSubscription = languageChangeController.stream.listen((String newCountryCode) {
      _updateCurrencyForCountryCode(newCountryCode);
      _updatePriceForCountryCode(newCountryCode);
    });
  }

  // 국가 코드에 따라 통화 정보 업데이트
  void _updateCurrencyForCountryCode(String countryCode) async {
    try {
      print('언어 변경 감지 - 국가 코드: $countryCode');

      if (_currencyController.isEmpty()) {
        await _currencyController.loadCurrencyData();
      }

      Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(countryCode);
      if (currencyInfo != null) {
        currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
        currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
        print('언어 변경에 따른 통화 정보 업데이트: $countryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
      }
    } catch (e) {
      print('통화 정보 업데이트 중 오류 (컨트롤러가 이미 dispose됨): $e');
    }
  }

  // 국가 코드에 따라 시간당 요금 업데이트
  void _updatePriceForCountryCode(String countryCode) {
    try {
      if (_priceController.isEmpty()) {
        _loadPriceDataAndUpdatePrice(countryCode);
      } else {
        _priceController.getPriceForCountryCode(countryCode);
        print('언어 변경에 따른 시간당 요금 업데이트: $countryCode -> ${_priceController.currentPrice}');
      }
    } catch (e) {
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
      await _translationController.loadTranslations();
      await _currencyController.loadCurrencyData();
      await _priceController.loadPricePerHourData();
      await _locationController.loadUserLocation(uid);

      final userData = await _documentController.loadUserDocument(uid);

      String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
      print('초기화 - 유효 국가 코드: $effectiveCountryCode (위치 코드: ${_locationController.userLocationCode}, 앱 설정: $currentCountryCode)');

      if (userData != null) {
        if (userData['pricePerHour'] != null) {
          _priceController.updatePrice(userData['pricePerHour']);
          print('기존 pricePerHour 값 사용: ${_priceController.currentPrice}');
        } else {
          _priceController.getPriceForCountryCode(effectiveCountryCode);
        }

        if (userData['currencySymbol'] != null) {
          currencySymbolNotifier.value = userData['currencySymbol'];
          print('기존 currencySymbol 값 사용: ${currencySymbolNotifier.value}');
        } else {
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
            print('국가 코드 기반 통화 심볼 설정: $effectiveCountryCode -> ${currencySymbolNotifier.value}');
          }
        }

        if (userData['currencyCode'] != null) {
          currencyCodeNotifier.value = userData['currencyCode'];
          print('기존 currencyCode 값 사용: ${currencyCodeNotifier.value}');
        } else {
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
            print('국가 코드 기반 통화 코드 설정: $effectiveCountryCode -> ${currencyCodeNotifier.value}');
          }
        }
      } else {
        _priceController.getPriceForCountryCode(effectiveCountryCode);

        Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
        if (currencyInfo != null) {
          currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
          currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
          print('국가 코드 기반 통화 정보 설정: $effectiveCountryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
        } else {
          currencySymbolNotifier.value = '₩';
          currencyCodeNotifier.value = 'KRW';
          print('통화 정보 설정 실패, 기본값 사용: ₩ (KRW)');
        }
      }
    } catch (e) {
      debugPrint('Error in initialization: $e');
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

  void updateValidationState() {
    isValidNotifier.value = isValid();
  }

  void updateCurrencySymbol(String symbol) {
    _currencyController.updateCurrencySymbol(currencySymbolNotifier, symbol);
  }

  void updateCurrencyCode(String code) {
    _currencyController.updateCurrencyCode(currencyCodeNotifier, code);
  }

  Future<void> updatePriceAndCurrencyForLocation(String location) async {
    try {
      _locationController.updateLocation(location);

      String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
      print('위치 변경 - 유효 국가 코드: $effectiveCountryCode');

      if (_currencyController.isEmpty()) {
        await _currencyController.loadCurrencyData();
      }

      if (_priceController.isEmpty()) {
        await _priceController.loadPricePerHourData();
      }

      _priceController.getPriceForCountryCode(effectiveCountryCode);

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
      final result = await _referralController.validateReferrerCode(code, uid);
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

      final docRef = _firestore.collection("tripfriends_users").doc(uid);
      final currentDoc = await docRef.get();
      Map<String, dynamic>? userData = currentDoc.data();

      if (userData == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
      print('저장 전 현재 국가 코드 확인: $effectiveCountryCode (앱 설정: $currentCountryCode)');

      Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
      if (currencyInfo != null) {
        currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
        currencyCodeNotifier.value = currencyInfo['code'] ?? 'KRW';
        print('저장 전 최종 통화 정보 확인: $effectiveCountryCode -> ${currencySymbolNotifier.value} (${currencyCodeNotifier.value})');
      }

      _priceController.getPriceForCountryCode(effectiveCountryCode);

      final updateData = _prepareUpdateData();

      if (validatedReferrerCode != null && referrerUid != null) {
        await _referralController.updateReferrerApproval(uid, referrerUid!, validatedReferrerCode!, updateData);
      }

      await _documentController.updateUserDocument(uid, updateData);
      print('✅ 상세 정보 업데이트 완료');

      try {
        await _saveSessionAndRefreshToken();
      } catch (e) {
        print('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
      }

      if (context.mounted) {
        await RegisterCompletionDialog.show(context);

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      print('❌ 상세 정보 업데이트 실패: $e');
      print('❌ 저장 실패: $e');
      rethrow;
    } finally {
      isSavingNotifier.value = false;
    }
  }

  Map<String, dynamic> _prepareUpdateData() {
    return {
      "languages": selectedLanguagesNotifier.value,
      "pricePerHour": _priceController.currentPrice,
      "updatedAt": FieldValue.serverTimestamp(),
      "introduction": introductionController.text.trim(),
    };
  }

  Future<void> _saveSessionAndRefreshToken() async {
    try {
      await _authController.saveSessionAndRefreshToken(uid);
      print('✅ 세션 및 토큰 처리 완료');
    } catch (e) {
      print('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
    }
  }

  Future<void> loadExistingData() async {
    try {
      final userData = await _documentController.loadUserDocument(uid);

      if (userData != null) {
        selectedLanguagesNotifier.value = List<String>.from(userData['languages'] ?? []);

        if (userData['pricePerHour'] != null) {
          _priceController.updatePrice(userData['pricePerHour']);
          print('기존 pricePerHour 값 사용: ${_priceController.currentPrice}');
        } else {
          if (userData['location'] != null) {
            _locationController.updateLocation(userData['location'] as String);
          }

          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
          _priceController.getPriceForCountryCode(effectiveCountryCode);
        }

        if (userData['currencySymbol'] != null) {
          currencySymbolNotifier.value = userData['currencySymbol'];
        } else {
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
          Map<String, String>? currencyInfo = _currencyController.getCurrencyForCountry(effectiveCountryCode);
          if (currencyInfo != null) {
            currencySymbolNotifier.value = currencyInfo['symbol'] ?? '₩';
          }
        }

        if (userData['currencyCode'] != null) {
          currencyCodeNotifier.value = userData['currencyCode'];
        } else {
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
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
    _languageChangeSubscription?.cancel();
    isSavingNotifier.dispose();
    isValidNotifier.dispose();
    isCheckingReferrerCode.dispose();
    currencySymbolNotifier.dispose();
    currencyCodeNotifier.dispose();
    referrerCodeErrorNotifier.dispose();
    selectedLanguagesNotifier.dispose();
    referrerCodeController.dispose();
    introductionController.dispose();
    referrerCodeSuccessNotifier.dispose();
  }
}