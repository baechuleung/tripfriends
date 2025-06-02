import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class TermsAgreementController {
  final ValueNotifier<bool> serviceTermsAgreedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> privacyTermsAgreedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> locationTermsAgreedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> allTermsAgreedNotifier = ValueNotifier<bool>(false);

  // 상태 변경 콜백
  final VoidCallback? onChanged;

  // 번역 관련
  Map<String, String> currentLabels = {
    "terms_agreement": "이용약관 동의",
    "agree_all": "모든 약관에 동의",
    "service_terms": "[필수] 서비스 이용약관",
    "privacy_terms": "[필수] 개인정보수집/이용동의",
    "location_terms": "[필수] 위치기반 서비스 이용약관 동의",
  };

  TermsAgreementController({this.onChanged}) {
    serviceTermsAgreedNotifier.addListener(_checkAllTermsAgreed);
    privacyTermsAgreedNotifier.addListener(_checkAllTermsAgreed);
    locationTermsAgreedNotifier.addListener(_checkAllTermsAgreed);
    allTermsAgreedNotifier.addListener(_setAllTerms);
  }

  bool get serviceTermsAgreed => serviceTermsAgreedNotifier.value;
  set serviceTermsAgreed(bool value) {
    serviceTermsAgreedNotifier.value = value;
  }

  bool get privacyTermsAgreed => privacyTermsAgreedNotifier.value;
  set privacyTermsAgreed(bool value) {
    privacyTermsAgreedNotifier.value = value;
  }

  bool get locationTermsAgreed => locationTermsAgreedNotifier.value;
  set locationTermsAgreed(bool value) {
    locationTermsAgreedNotifier.value = value;
  }

  bool get allTermsAgreed => allTermsAgreedNotifier.value;
  set allTermsAgreed(bool value) {
    allTermsAgreedNotifier.value = value;
  }

  bool isAllTermsAgreed() {
    return serviceTermsAgreedNotifier.value &&
        privacyTermsAgreedNotifier.value &&
        locationTermsAgreedNotifier.value;
  }

  void _checkAllTermsAgreed() {
    allTermsAgreedNotifier.value = isAllTermsAgreed();
    _notifyChanged();
  }

  void _setAllTerms() {
    if (allTermsAgreedNotifier.value) {
      serviceTermsAgreedNotifier.value = true;
      privacyTermsAgreedNotifier.value = true;
      locationTermsAgreedNotifier.value = true;
    }
    _notifyChanged();
  }

  void _notifyChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  Map<String, dynamic> getTermsAgreedMap() {
    return {
      "service": serviceTermsAgreedNotifier.value,
      "privacy": privacyTermsAgreedNotifier.value,
      "location": locationTermsAgreedNotifier.value,
      "agreedAt": FieldValue.serverTimestamp(),
    };
  }

  Future<void> loadTranslations(String currentCountryCode) async {
    try {
      final String translationJson = await rootBundle.loadString('assets/data/auth_translations.json');
      final translationData = json.decode(translationJson);

      final translations = translationData['translations'];
      if (translations['terms_agreement'] != null &&
          translations['agree_all'] != null &&
          translations['service_terms'] != null &&
          translations['privacy_terms'] != null &&
          translations['location_terms'] != null) {
        currentLabels = {
          "terms_agreement": translations['terms_agreement'][currentCountryCode] ?? "이용약관 동의",
          "agree_all": translations['agree_all'][currentCountryCode] ?? "모든 약관에 동의",
          "service_terms": translations['service_terms'][currentCountryCode] ?? "[필수] 서비스 이용약관",
          "privacy_terms": translations['privacy_terms'][currentCountryCode] ?? "[필수] 개인정보수집/이용동의",
          "location_terms": translations['location_terms'][currentCountryCode] ?? "[필수] 위치기반 서비스 이용약관 동의",
        };
      }
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  void dispose() {
    serviceTermsAgreedNotifier.dispose();
    privacyTermsAgreedNotifier.dispose();
    locationTermsAgreedNotifier.dispose();
    allTermsAgreedNotifier.dispose();
  }
}