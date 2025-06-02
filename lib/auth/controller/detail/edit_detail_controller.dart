// edit_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'auth_controller.dart';
import 'currency_controller.dart';
import 'document_controller.dart';
import 'introduction_controller.dart';
import 'languages_controller.dart';
import 'point_controller.dart';
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
  final PointController _pointController = PointController();
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
    // 초기화 작업을 비동기로 처리
    _initialize();

    // 값 변경 상태 업데이트를 위한 리스너 등록
    selectedLanguagesNotifier.addListener(updateValidationState);
    introductionController.addListener(updateValidationState);
  }

  // 초기화 작업을 비동기로 처리하는 함수
  Future<void> _initialize() async {
    try {
      // 각 컨트롤러 초기화
      await _translationController.loadTranslations();
      await _currencyController.loadCurrencyData();
      await _priceController.loadPricePerHourData();
      await _locationController.loadUserLocation(uid);

      // 기존 데이터 로드
      await loadExistingData();
    } catch (e) {
      debugPrint('Error in initialization: $e');
    }
  }

  // 국가 코드에 따라 시간당 요금 업데이트
  void _updatePriceForCountryCode(String countryCode) {
    _priceController.getPriceForCountryCode(countryCode);
    print('국가 코드에 따른 시간당 요금 업데이트: $countryCode -> ${_priceController.currentPrice}');
  }

  // 기존 데이터 로드
  Future<void> loadExistingData() async {
    try {
      final userData = await _documentController.loadUserDocument(uid);

      if (userData != null) {
        // 원본 데이터 저장
        _originalData = Map<String, dynamic>.from(userData);

        if (userData['languages'] != null) {
          selectedLanguagesNotifier.value = List<String>.from(userData['languages']);
        }

        if (userData['pricePerHour'] != null) {
          _priceController.updatePrice(userData['pricePerHour']);
          print('기존 pricePerHour 값 사용: ${_priceController.currentPrice}');
        } else {
          // 유효한 국가 코드 결정
          String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
          _updatePriceForCountryCode(effectiveCountryCode);
        }

        currencySymbolNotifier.value = userData['currencySymbol'] ?? '₩';
        currencyCodeNotifier.value = userData['currencyCode'] ?? 'KRW';
        introductionController.text = userData['introduction'] ?? '';

        // 유효성 상태 업데이트
        updateValidationState();

        // 데이터 로드 상태 업데이트
        isDataLoadedNotifier.value = true;

        // 데이터 로드 완료 콜백 호출
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

  // 변경 사항이 있는지 확인
  bool hasChanges() {
    if (_originalData.isEmpty) return false;

    // 언어 비교
    if (_originalData['languages'] != null) {
      final originalLanguages = List<String>.from(_originalData['languages']);
      if (!_areListsEqual(originalLanguages, selectedLanguagesNotifier.value)) {
        return true;
      }
    } else if (selectedLanguagesNotifier.value.isNotEmpty) {
      return true;
    }

    // 가격 비교
    final originalPrice = _originalData['pricePerHour']?.toString() ?? '';
    final currentPrice = _priceController.currentPrice.toString();
    if (originalPrice != currentPrice) {
      return true;
    }

    // 통화 심볼 비교
    final originalSymbol = _originalData['currencySymbol'] ?? '₩';
    if (originalSymbol != currencySymbolNotifier.value) {
      return true;
    }

    // 통화 코드 비교
    final originalCode = _originalData['currencyCode'] ?? 'KRW';
    if (originalCode != currencyCodeNotifier.value) {
      return true;
    }

    // 자기소개 비교
    final originalIntro = _originalData['introduction'] ?? '';
    if (originalIntro != introductionController.text.trim()) {
      return true;
    }

    return false;
  }

  // 리스트 비교 헬퍼 함수
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
      final result = await _referralController.validateReferrerCode(code);
      if (result.isValid) {
        referrerCodeErrorNotifier.value = null;
        referrerCodeSuccessNotifier.value = _translationController.getTranslatedMessage("referrer_code_matched");
        validatedReferrerCode = code;
        referrerUid = result.referrerUid;

        // 추천인 정보 업데이트
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

  // 업데이트 메서드
  Future<void> saveDetailChanges(BuildContext context) async {
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

      // 업데이트할 데이터 준비
      final updateData = _prepareUpdateData(await _pointController.getExistingPointValue(uid));

      // 추천인 코드가 있는 경우 추천인 정보 업데이트
      if (validatedReferrerCode != null && referrerUid != null) {
        await _referralController.updateReferrerApproval(
            uid, referrerUid!, validatedReferrerCode!, updateData);
      }

      // Firestore 문서 업데이트
      await _documentController.updateUserDocument(uid, updateData);
      print('✅ 상세 정보 업데이트 완료');

      // 추천인에게 포인트 지급 처리 (문서 업데이트 후에 실행)
      if (validatedReferrerCode != null && referrerUid != null) {
        await _processReferralPointsReward(userData['name'] ?? '회원');
      }

// 자기소개 길이가 포인트 지급 조건을 충족하는지 확인
      if (hasChanges() && !isDetailCompletedBefore &&
          _validationController.isIntroductionEligibleForPoints(introductionController.text)) {
        try {
          // 사용자의 실제 currencyCode 사용 (데이터베이스에서 가져온 값)
          String userCurrencyCode = userData['currencyCode'] ?? currencyCodeNotifier.value;

          // 프로필 수정 시 포인트 지급
          await _pointController.addProfileCompletionPoints(
              uid,
              userCurrencyCode, // 실제 DB의 통화 코드 사용
              introductionController.text.trim().length
          );
          print('✅ 프로필 수정 시 자기소개 포인트 지급 완료 (통화: $userCurrencyCode)');
        } catch (e) {
          print('⚠️ 적립금 지급 중 오류: $e');
        }
      } else {
        _validationController.logPointsSkipReason(
            isDetailCompletedBefore,
            introductionController.text
        );
      }

      try {
        await _authController.saveSessionAndRefreshToken(uid);
      } catch (e) {
        print('⚠️ 세션 저장 중 오류 발생 (무시됨): $e');
      }

      // 성공 메시지 출력 - 스낵바 대신 디버그 프린트로 대체
      print('✅ 변경 사항이 저장되었습니다.');
      if (context.mounted) {
        Navigator.pop(context, true); // true를 반환하여 변경 사항이 있음을 알림
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

  // 추천인 포인트 처리 추가
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

  void updateCurrencySymbol(String symbol) {
    _currencyController.updateCurrencySymbol(currencySymbolNotifier, symbol);
  }

  void updateCurrencyCode(String code) {
    _currencyController.updateCurrencyCode(currencyCodeNotifier, code);
  }

  // 위치 정보 변경 시 가격과 통화 정보 업데이트
  Future<void> updatePriceAndCurrencyForLocation(String location) async {
    _locationController.updateLocation(location);

    if (_currencyController.isEmpty()) {
      await _currencyController.loadCurrencyData();
    }

    if (_priceController.isEmpty()) {
      await _priceController.loadPricePerHourData();
    }

    // 유효한 국가 코드 결정
    String effectiveCountryCode = _locationController.userLocationCode ?? currentCountryCode;
    _updatePriceForCountryCode(effectiveCountryCode);

    _currencyController.setCurrencyBasedOnLocation(
        currencySymbolNotifier,
        currencyCodeNotifier,
        _locationController.userLocationCode
    );
  }

  void dispose() {
    // Notifiers
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

    // Controllers
    referrerCodeController.dispose();
    introductionController.dispose();
  }
}