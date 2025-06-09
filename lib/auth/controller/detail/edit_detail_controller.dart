import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'auth_controller.dart';
import 'currency_controller.dart';
import 'document_controller.dart';
import 'introduction_controller.dart';
import 'languages_controller.dart';
import 'price_controller.dart';
import 'referral_controller.dart';
import 'translation_controller.dart';
import 'user_location_controller.dart';
import 'validation_controller.dart';
import '../../../../main.dart';

class EditDetailController {
  // 필수 식별자
  final String uid;

  // 콜백 함수
  final Function()? onDataLoaded;

  // 컨트롤러 인스턴스들
  final AuthController _authController = AuthController();
  final CurrencyController _currencyController = CurrencyController();
  final DocumentController _documentController = DocumentController();
  final IntroductionController _introductionController = IntroductionController();
  final LanguagesController _languagesController = LanguagesController();
  final PriceController _priceController = PriceController();
  final ReferralController _referralController = ReferralController();
  final TranslationController _translationController = TranslationController();
  final UserLocationController _locationController = UserLocationController();
  final ValidationController _validationController = ValidationController();

  // ValueNotifier들
  final ValueNotifier<bool> isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isValidNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isDataLoadedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> currencySymbolNotifier = ValueNotifier<String>('₩');
  final ValueNotifier<String> currencyCodeNotifier = ValueNotifier<String>('KRW');
  final ValueNotifier<List<String>> selectedLanguagesNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<String?> referrerCodeErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isCheckingReferrerCode = ValueNotifier<bool>(false);
  final ValueNotifier<String?> referrerCodeSuccessNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<Map<String, String>> referrerInfoNotifier = ValueNotifier<Map<String, String>>({});

  // TextEditingController들
  final TextEditingController referrerCodeController = TextEditingController();
  final TextEditingController introductionController;

  // 추천인 코드 관련
  String? validatedReferrerCode;
  String? referrerUid;

  // Firebase 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 원본 데이터 저장 (변경 감지용)
  Map<String, dynamic> _originalData = {};

  EditDetailController({
    required this.uid,
    this.onDataLoaded,
  }) : introductionController = IntroductionController().introductionController {
    _initialize();
    selectedLanguagesNotifier.addListener(updateValidationState);
    introductionController.addListener(updateValidationState);
  }

  Future<void> _initialize() async {
    try {
      await _translationController.loadTranslations();
      await _currencyController.loadCurrencyData();
      await _priceController.loadPricePerHourData();
      await _locationController.loadUserLocation(uid);
      await loadExistingData();
    } catch (e) {
      debugPrint('Error in initialization: $e');
    }
  }

  void _updatePriceForCountryCode(String countryCode) {
    _priceController.getPriceForCountryCode(countryCode);
    print('국가 코드에 따른 시간당 요금 업데이트: $countryCode -> ${_priceController.currentPrice}');
  }

  Future<void> loadExistingData() async {
    try {
      final userData = await _documentController.loadUserDocument(uid);

      if (userData != null) {
        _originalData = Map<String, dynamic>.from(userData);

        if (userData['languages'] != null) {
          selectedLanguagesNotifier.value = List<String>.from(userData['languages']);
        }

        if (userData['pricePerHour'] != null) {
          _priceController.updatePrice(userData['pricePerHour']);
          print('기존 pricePerHour 값 사용: ${_priceController.currentPrice}');
        } else {
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
          _updatePriceForCountryCode(effectiveCountryCode);
        }

        currencySymbolNotifier.value = userData['currencySymbol'] ?? '₩';
        currencyCodeNotifier.value = userData['currencyCode'] ?? 'KRW';
        introductionController.text = userData['introduction'] ?? '';

        if (userData['referrer'] != null) {
          final referrerData = userData['referrer'] as Map<String, dynamic>;
          if (referrerData['code'] != null) {
            referrerCodeController.text = referrerData['code'];
            validatedReferrerCode = referrerData['code'];
            referrerUid = referrerData['uid'];
            referrerCodeSuccessNotifier.value = _translationController.getTranslatedMessage("referrer_code_matched");

            referrerInfoNotifier.value = {
              'uid': referrerData['uid'] ?? '',
              'code': referrerData['code'] ?? '',
              'name': '추천인 코드가 확인되었습니다'
            };
          }
        }

        updateValidationState();
        isDataLoadedNotifier.value = true;

        if (onDataLoaded != null) {
          onDataLoaded!();
        }
      }
    } catch (e) {
      print('❌ 기존 데이터 로드 실패: $e');
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

  bool hasChanges() {
    if (_originalData.isEmpty) return false;

    if (_originalData['languages'] != null) {
      final originalLanguages = List<String>.from(_originalData['languages']);
      if (!_areListsEqual(originalLanguages, selectedLanguagesNotifier.value)) {
        return true;
      }
    } else if (selectedLanguagesNotifier.value.isNotEmpty) {
      return true;
    }

    final originalPrice = _originalData['pricePerHour']?.toString() ?? '';
    final currentPrice = _priceController.currentPrice.toString();
    if (originalPrice != currentPrice) {
      return true;
    }

    final originalSymbol = _originalData['currencySymbol'] ?? '₩';
    if (originalSymbol != currencySymbolNotifier.value) {
      return true;
    }

    final originalCode = _originalData['currencyCode'] ?? 'KRW';
    if (originalCode != currencyCodeNotifier.value) {
      return true;
    }

    final originalIntro = _originalData['introduction'] ?? '';
    if (originalIntro != introductionController.text.trim()) {
      return true;
    }

    return false;
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
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

        if (result.referrerUid != null) {
          referrerInfoNotifier.value = {
            'uid': result.referrerUid!,
            'code': code
          };
        }

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

  void handleLanguageSelection(String language, bool? value) {
    if (value == true) {
      if (!selectedLanguagesNotifier.value.contains(language)) {
        final List<String> updatedLanguages = [...selectedLanguagesNotifier.value, language];
        selectedLanguagesNotifier.value = updatedLanguages;
      }
    } else {
      final List<String> updatedLanguages = selectedLanguagesNotifier.value
          .where((l) => l != language)
          .toList();
      selectedLanguagesNotifier.value = updatedLanguages;
    }
    updateValidationState();
  }

  Future<void> saveDetailChanges(BuildContext context) async {
    try {
      isSavingNotifier.value = true;
      print('상세 정보 업데이트 시작 - UID: $uid');

      final docRef = _firestore.collection("tripfriends_users").doc(uid);
      final currentDoc = await docRef.get();
      Map<String, dynamic>? userData = currentDoc.data();

      if (userData == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      final updateData = _prepareUpdateData();

      if (validatedReferrerCode != null && referrerUid != null) {
        await _referralController.updateReferrerApproval(
            uid, referrerUid!, validatedReferrerCode!, updateData);
      }

      await _documentController.updateUserDocument(uid, updateData);
      print('✅ 상세 정보 업데이트 완료');

      try {
        await _authController.saveSessionAndRefreshToken(uid);
      } catch (e) {
        print('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
      }

      print('✅ 변경 사항이 저장되었습니다.');
      if (context.mounted) {
        Navigator.pop(context, true);
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

  void updateCurrencySymbol(String symbol) {
    _currencyController.updateCurrencySymbol(currencySymbolNotifier, symbol);
  }

  void updateCurrencyCode(String code) {
    _currencyController.updateCurrencyCode(currencyCodeNotifier, code);
  }

  Future<void> updatePriceAndCurrencyForLocation(String location) async {
    _locationController.updateLocation(location);

    if (_currencyController.isEmpty()) {
      await _currencyController.loadCurrencyData();
    }

    if (_priceController.isEmpty()) {
      await _priceController.loadPricePerHourData();
    }

    String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
    _updatePriceForCountryCode(effectiveCountryCode);

    _currencyController.setCurrencyBasedOnLocation(
        currencySymbolNotifier,
        currencyCodeNotifier,
        _locationController.userLocationCode
    );
  }

  void dispose() {
    isSavingNotifier.dispose();
    isValidNotifier.dispose();
    isDataLoadedNotifier.dispose();
    currencySymbolNotifier.dispose();
    currencyCodeNotifier.dispose();
    selectedLanguagesNotifier.dispose();
    referrerCodeErrorNotifier.dispose();
    referrerCodeSuccessNotifier.dispose();
    isCheckingReferrerCode.dispose();
    referrerInfoNotifier.dispose();
    referrerCodeController.dispose();
    introductionController.dispose();
  }
}