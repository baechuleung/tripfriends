import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocationController {
  // 유저의 위치 정보
  String? userLocationCode;
  String? userLocationFull;

  // Firebase 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 문자열에서 국가 코드 추출 함수
  String? _extractCountryCode(String? location) {
    if (location == null || location.isEmpty) return null;

    // 콤마로 분리되어 있으면 마지막 부분이 국가 코드
    final parts = location.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }

    // 그 외의 경우, 전체 문자열이 국가 코드일 수 있음
    return location.trim();
  }

  // 유저의 location 정보를 가져오는 함수
  Future<void> loadUserLocation(String uid) async {
    try {
      final docSnapshot = await _firestore.collection("tripfriends_users").doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final location = data['location'] as String?;

        if (location != null && location.isNotEmpty) {
          userLocationFull = location;
          userLocationCode = _extractCountryCode(location);
          print('유저 위치 정보 로드 완료: $userLocationFull (국가 코드: $userLocationCode)');
        } else {
          print('유저 위치 정보가 비어있음');
        }
      } else {
        print('유저 문서를 찾을 수 없음');
      }
    } catch (e) {
      debugPrint('Error loading user location: $e');
    }
  }

  // 위치 정보 업데이트
  void updateLocation(String location) {
    userLocationFull = location;
    userLocationCode = _extractCountryCode(location);
    print('위치 정보 업데이트 완료: $userLocationFull (국가 코드: $userLocationCode)');
  }
}