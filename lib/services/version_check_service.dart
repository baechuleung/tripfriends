import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'version_update_popup.dart';

class VersionCheckService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 버전 정보 체크 및 업데이트
  static Future<void> checkVersion(BuildContext context) async {
    try {
      // 현재 앱 버전 가져오기
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;

      debugPrint('📱 현재 앱 버전: $currentVersion+$buildNumber');

      // Firestore에서 버전 정보 가져오기 (컬렉션에서 가져오기)
      final QuerySnapshot versionSnapshot = await _firestore
          .collection('tripfriends_version_info')
          .limit(1)
          .get();

      if (versionSnapshot.docs.isEmpty) {
        debugPrint('❌ 버전 정보가 없습니다. 초기 버전 정보를 생성합니다.');

        // 초기 버전 정보 생성
        await _firestore
            .collection('tripfriends_version_info')
            .add({
          'minimum_version': currentVersion, // 현재 버전을 최소 버전으로 설정
          'latest_version': currentVersion,  // 현재 버전을 최신 버전으로 설정
          'update_message': '', // 빈 문자열로 설정
          'ios_url': 'https://apps.apple.com/app/id123456789', // 실제 앱스토어 URL로 변경 필요
          'android_url': 'https://play.google.com/store/apps/details?id=com.yourcompany.tripfriends', // 실제 플레이스토어 URL로 변경 필요
          'updated_at': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ 초기 버전 정보 생성 완료: $currentVersion');
        return;
      }

      // 첫 번째 문서 가져오기
      final DocumentSnapshot versionDoc = versionSnapshot.docs.first;
      final Map<String, dynamic> versionData = versionDoc.data() as Map<String, dynamic>;

      final String? minimumVersion = versionData['minimum_version'];
      final String? latestVersion = versionData['latest_version'];
      final String? updateMessage = versionData['update_message'];
      final String? iosUrl = versionData['ios_url'];
      final String? androidUrl = versionData['android_url'];

      debugPrint('🔄 최소 버전: $minimumVersion');
      debugPrint('🔄 최신 버전: $latestVersion');

      // 버전 비교
      if (minimumVersion != null && _isVersionLower(currentVersion, minimumVersion)) {
        // 필수 업데이트
        if (context.mounted) {
          showVersionUpdatePopup(
            context: context,
            isForceUpdate: true,
            message: updateMessage ?? '',
            iosUrl: iosUrl,
            androidUrl: androidUrl,
          );
        }
      } else if (latestVersion != null && _isVersionLower(currentVersion, latestVersion)) {
        // 선택 업데이트
        if (context.mounted) {
          showVersionUpdatePopup(
            context: context,
            isForceUpdate: false,
            message: updateMessage ?? '',
            iosUrl: iosUrl,
            androidUrl: androidUrl,
          );
        }
      }

    } catch (e) {
      debugPrint('❌ 버전 체크 중 오류 발생: $e');
    }
  }

  // 버전 비교 함수 (semantic versioning)
  static bool _isVersionLower(String currentVersion, String targetVersion) {
    try {
      List<int> current = currentVersion.split('.').map((e) => int.parse(e)).toList();
      List<int> target = targetVersion.split('.').map((e) => int.parse(e)).toList();

      // 버전 길이 맞추기
      while (current.length < target.length) current.add(0);
      while (target.length < current.length) target.add(0);

      // 버전 비교
      for (int i = 0; i < current.length; i++) {
        if (current[i] < target[i]) return true;
        if (current[i] > target[i]) return false;
      }

      return false;
    } catch (e) {
      debugPrint('❌ 버전 비교 중 오류: $e');
      return false;
    }
  }

  // 버전 정보를 Firestore에 저장 (관리자용)
  static Future<void> setVersionInfo({
    required String minimumVersion,
    required String latestVersion,
    required String updateMessage,
    required String iosUrl,
    required String androidUrl,
  }) async {
    try {
      // 기존 버전 정보 삭제
      final QuerySnapshot existingDocs = await _firestore
          .collection('tripfriends_version_info')
          .get();

      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      // 새 버전 정보 추가
      await _firestore
          .collection('tripfriends_version_info')
          .add({
        'minimum_version': minimumVersion,
        'latest_version': latestVersion,
        'update_message': updateMessage,
        'ios_url': iosUrl,
        'android_url': androidUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ 버전 정보 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 버전 정보 업데이트 실패: $e');
    }
  }
}