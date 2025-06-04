import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'name_controller.dart';
import 'age_controller.dart';
import 'gender_controller.dart';
import 'nationality_controller.dart';
import 'city_controller.dart';
import 'phone_controller.dart';
import 'profile_controller.dart';
import 'terms_agreement_controller.dart';
import 'models/media_info.dart';
import '../../utils/point_util.dart';

class EditDefaultController {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 디폴트 컨트롤러들
  late final NameController nameController;
  late final AgeController ageController;
  late final GenderController genderController;
  late final NationalityController nationalityController;
  late final CityController cityController;
  late final PhoneController phoneController;
  late final ProfileController profileController;
  late final TermsAgreementController termsAgreementController;

  // 상태 관리
  final ValueNotifier<bool> isAllFieldsFilled = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRegisteringNotifier = ValueNotifier<bool>(false);

  // 콜백
  final Function()? onDataLoaded;

  EditDefaultController({
    required this.uid,
    this.onDataLoaded,
  }) {
    _initControllers();
    loadExistingData();
  }

  void _initControllers() {
    // 상태 변경 콜백을 실행하는 함수
    void updateState() => _checkAllFieldsFilled();

    // 각 컨트롤러 초기화
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

  // 기존 데이터 로드
  Future<void> loadExistingData() async {
    try {
      final docSnapshot = await _firestore.collection("tripfriends_users").doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // 이름 로드
        nameController.nameController.text = data['name'] ?? '';

        // 성별 로드
        genderController.gender = data['gender'] ?? '';

        // 생년월일 로드
        if (data['birthDate'] != null) {
          final birthDate = data['birthDate'] as Map<String, dynamic>;
          ageController.birthYearController.text = birthDate['year']?.toString() ?? '';
          ageController.birthMonthController.text = birthDate['month']?.toString() ?? '';
          ageController.birthDayController.text = birthDate['day']?.toString() ?? '';

          // ValueNotifier 값 업데이트
          ageController.updateFromController();
        }

        // 국가/도시 로드
        if (data['location'] != null) {
          if (data['location'] is Map) {
            final locationMap = data['location'] as Map<String, dynamic>;
            if (locationMap['nationality'] != null) {
              nationalityController.nationalityController.text = locationMap['nationality'];
              // ValueNotifier 값 업데이트
              nationalityController.updateFromController();
            }

            // 국가 설정 후 일정 시간 대기하여 도시 목록 로드 완료 후 도시 설정
            await Future.delayed(const Duration(milliseconds: 500));

            if (locationMap['city'] != null) {
              cityController.cityController.text = locationMap['city'];
              // ValueNotifier 값 업데이트
              cityController.updateFromController();
            }
          } else if (data['location'] is String) {
            nationalityController.nationalityController.text = data['location'];
            nationalityController.updateFromController();
          }
        }

        // 전화번호 로드
        if (data['phoneData'] != null && data['phoneData'] is Map) {
          final phoneData = data['phoneData'] as Map<String, dynamic>;
          phoneController.dialCode = phoneData['countryCode'] ?? '+82';
          phoneController.phoneController.text = phoneData['number'] ?? '';
        }

        // 프로필 미디어 로드
        if (data['profileMediaList'] != null && data['profileMediaList'] is List) {
          final mediaList = List<Map<String, dynamic>>.from(data['profileMediaList']);
          final List<MediaInfo> profileMedia = mediaList.map((item) => MediaInfo.fromMap(item)).toList();

          profileController.profileMediaNotifier.value = profileMedia;

          if (profileMedia.isNotEmpty && profileMedia[0].type == MediaType.image) {
            profileController.profileImageNotifier.value = profileMedia[0].path;
          }
        }

        // 약관 동의 상태 로드
        if (data['termsAgreed'] != null) {
          final termsData = data['termsAgreed'] as Map<String, dynamic>;
          termsAgreementController.serviceTermsAgreed = termsData['service'] ?? false;
          termsAgreementController.privacyTermsAgreed = termsData['privacy'] ?? false;
          termsAgreementController.locationTermsAgreed = termsData['location'] ?? false;
        }

        // UI 상태 업데이트
        _checkAllFieldsFilled();

        if (onDataLoaded != null) {
          onDataLoaded!();
        }
      }
    } catch (e) {
      print('데이터 로드 중 오류 발생: $e');
      isAllFieldsFilled.value = false;
    }
  }

  // saveProfileToFirestore 메서드 수정
  Future<void> saveProfileToFirestore() async {
    try {
      isRegisteringNotifier.value = true;

      // 1. 프로필 미디어 업로드
      final mediaUploadResult = await profileController.uploadProfileMedia();
      final String? profileImageUrl = mediaUploadResult['profileImageUrl'];
      final List<Map<String, dynamic>> mediaUrls = mediaUploadResult['mediaUrls'];

      // 2. 위치 데이터 구성
      Map<String, dynamic> locationMap = {
        "nationality": nationalityController.nationality,
        "city": cityController.city,
      };

      // 3. 통화 정보 설정
      String currencySymbol = '';
      String currencyCode = '';
      final nationalityCode = nationalityController.nationality;

      if (nationalityCode.isNotEmpty) {
        try {
          final String currencyJson = await rootBundle.loadString('assets/data/currency.json');
          final currencyData = json.decode(currencyJson);
          final currencies = currencyData['currencies'] as Map<String, dynamic>;

          if (currencies.containsKey(nationalityCode)) {
            final Map<String, dynamic> currencyInfo = currencies[nationalityCode];
            currencySymbol = currencyInfo['symbol'] ?? '';
            currencyCode = currencyInfo['code'] ?? '';
          }
        } catch (e) {
          print('통화 정보 설정 오류: $e');
        }
      }

      // 4. Firestore에 데이터 저장
      final userData = {
        "uid": uid,
        "name": nameController.name,
        "location": locationMap,
        "gender": genderController.gender,
        "birthDate": ageController.getBirthDateMap(),
        "phoneData": phoneController.getPhoneData(),
        "profileImageUrl": profileImageUrl,
        "profileMediaList": mediaUrls,
        "currencySymbol": currencySymbol,
        "currencyCode": currencyCode,
        "termsAgreed": termsAgreementController.getTermsAgreedMap(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection("tripfriends_users").doc(uid).update(userData);
      print('Firestore 사용자 데이터 저장 완료');

    } catch (e) {
      print('Firestore 등록 실패: $e');
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