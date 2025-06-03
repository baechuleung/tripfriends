import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../services/shared_preferences_service.dart';
import '../../utils/point_util.dart';
import 'name_controller.dart';
import 'age_controller.dart';
import 'gender_controller.dart';
import 'nationality_controller.dart';
import 'city_controller.dart';
import 'phone_controller.dart';
import 'profile_controller.dart';
import 'terms_agreement_controller.dart';
import 'models/media_info.dart';

class RegisterController {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 모든 컨트롤러
  late final NameController nameController;
  late final AgeController ageController;
  late final GenderController genderController;
  late final NationalityController nationalityController;
  late final CityController cityController;
  late final PhoneController phoneController;
  late final ProfileController profileController;
  late final TermsAgreementController termsAgreementController;

  // 모든 필드가 채워졌는지 확인하는 값
  final ValueNotifier<bool> isAllFieldsFilled = ValueNotifier<bool>(false);
  // 회원가입 진행 중 상태
  final ValueNotifier<bool> isRegisteringNotifier = ValueNotifier<bool>(false);

  RegisterController({required this.uid}) {
    // 모든 컨트롤러 초기화
    _initControllers();
  }

  void _initControllers() {
    // 상태 변경 콜백을 실행하는 함수
    void updateState() => _checkAllFieldsFilled();

    // 각 컨트롤러 초기화 (onChanged 콜백 전달)
    nameController = NameController(onChanged: updateState);
    ageController = AgeController(onChanged: updateState);
    genderController = GenderController(onChanged: updateState);
    nationalityController = NationalityController(onNationalityChanged: updateState);
    cityController = CityController(
      countryController: nationalityController.nationalityController,
      onCityChanged: updateState,
    );
    phoneController = PhoneController(onChanged: updateState);
    profileController = ProfileController(uid: uid, onChanged: updateState);
    termsAgreementController = TermsAgreementController(onChanged: updateState);
  }

  // 모든 필드가 채워졌는지 확인
  void _checkAllFieldsFilled() {
    final hasName = nameController.hasValidName();
    final hasAge = ageController.hasValidAge();
    final hasGender = genderController.hasValidGender();
    final hasNationality = nationalityController.hasValidNationality();
    final hasCity = cityController.hasValidCity();
    final hasPhone = phoneController.hasValidPhoneNumber();
    final hasProfile = profileController.hasValidProfileMedia();
    final hasTerms = termsAgreementController.isAllTermsAgreed();

    final allFieldsFilled = hasName &&
        hasAge &&
        hasGender &&
        hasNationality &&
        hasCity &&
        hasPhone &&
        hasProfile &&
        hasTerms;

    isAllFieldsFilled.value = allFieldsFilled;
  }

  // Firestore에 사용자 데이터 등록
  Future<void> registerToFirestore() async {
    try {
      isRegisteringNotifier.value = true;

      // 1. 프로필 미디어 업로드
      final mediaUploadResult = await profileController.uploadProfileMedia();
      final String? profileImageUrl = mediaUploadResult['profileImageUrl'];
      final List<Map<String, dynamic>> mediaUrls = mediaUploadResult['mediaUrls'];

      if (profileImageUrl == null) {
        throw Exception('프로필 이미지 업로드에 실패했습니다.');
      }

      // 2. 통화 정보 설정
      String currencySymbol = '';
      String currencyCode = '';
      final nationalityCode = nationalityController.nationality;

      if (nationalityCode.isNotEmpty) {
        try {
          final String currencyJson =
          await rootBundle.loadString('assets/data/currency.json');
          final currencyData = json.decode(currencyJson);
          final currencies = currencyData['currencies'] as Map<String, dynamic>;

          if (currencies.containsKey(nationalityCode)) {
            final Map<String, dynamic> currencyInfo = currencies[nationalityCode];
            currencySymbol = currencyInfo['symbol'] ?? '';
            currencyCode = currencyInfo['code'] ?? '';
          }
        } catch (e) {
          print('❌ 통화 정보 설정 오류: $e');
        }
      }

      // 3. 레퍼럴 코드 생성
      final referralCode = await profileController.generateUniqueReferralCode();
      final fcmToken = await SharedPreferencesService.getFCMToken();

      // 4. 동영상 업로드 여부 확인 (회원가입 시 보상 지급을 위해)
      bool hasVideo = false;
      if (profileController.profileMediaList.length > 1) {
        // 첫 번째는 무조건 이미지이므로, 두 번째부터 확인
        hasVideo = profileController.profileMediaList.skip(1).any((media) => media.type == MediaType.video);
      }

      // 5. Firestore에 사용자 데이터 저장
      final userData = {
        "uid": uid,
        "name": nameController.name,
        "location": {
          "nationality": nationalityController.nationality,
          "city": cityController.city,
        },
        "gender": genderController.gender,
        "birthDate": ageController.getBirthDateMap(),
        "phoneData": phoneController.getPhoneData(),
        "profileImageUrl": profileImageUrl,
        "profileMediaList": mediaUrls,
        "currencySymbol": currencySymbol,
        "currencyCode": currencyCode,
        "point": 0,
        "termsAgreed": termsAgreementController.getTermsAgreedMap(),
        "referrer_code": referralCode,
        "fcmToken": fcmToken, // FCM 토큰 추가
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "isApproved": false, // 승인여부 - 기본값 false
        "isActive": true, // 활동여부 - 기본값 true (계정은 활성화 상태로 시작)
        "isTicket": 15, // 이용권 초기 횟수
      };

      await _firestore.collection("tripfriends_users").doc(uid).set(userData);
      print('✅ Firestore 사용자 데이터 저장 완료');

      // 6. 동영상 업로드 보상 지급 (회원가입 시)
      if (hasVideo && currencyCode.isNotEmpty) {
        await PointUtil.addVideoUploadPoints(uid, currencyCode);
        print('✅ 회원가입 시 동영상 업로드 보상 지급 완료');
      }

    } catch (e) {
      print('❌ Firestore 등록 실패: $e');
      rethrow;
    } finally {
      isRegisteringNotifier.value = false;
    }
  }

  void dispose() {
    // 모든 컨트롤러 해제
    nameController.dispose();
    ageController.dispose();
    genderController.dispose();
    nationalityController.dispose();
    cityController.dispose();
    phoneController.dispose();
    profileController.dispose();
    termsAgreementController.dispose();

    // ValueNotifier 해제
    isAllFieldsFilled.dispose();
    isRegisteringNotifier.dispose();
  }
}