import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode

class RecommendedFriendsController {
  RecommendedFriendsController();

  // 사용자 정보 - 적립금 관련 속성 제거, 파트너 코드만 유지
  String referrerCode = "";

  // 친구 목록 정보
  List<Map<String, dynamic>> friends = [];
  bool isLoading = true;
  String errorMessage = '';

  // 번역 텍스트 가져오기
  String getTranslatedText(String key, String defaultText) {
    final language = currentCountryCode.toUpperCase();
    return MypageTranslations.getTranslation(key, language);
  }

  // 사용자 데이터 로드 - 적립금 관련 속성 제거
  Future<void> loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userData = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;

        // DB에서 파트너 코드만 가져오기
        referrerCode = data['referrer_code'] ?? "";
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // 오류 시 기본값 설정
      referrerCode = "";
    }
  }

  // 친구 목록 로드 - 현재 사용자의 referrer_approval 배열에서 친구 목록 가져오기
  Future<void> loadFriendsList() async {
    isLoading = true;
    errorMessage = '';
    friends = []; // 친구 목록 초기화

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isLoading = false;
        errorMessage = getTranslatedText('login_required', '로그인이 필요합니다');
        return;
      }

      // 현재 사용자의 정보를 가져와서 referrer_approval 배열 확인
      final currentUserData = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      if (!currentUserData.exists) {
        isLoading = false;
        errorMessage = getTranslatedText('user_not_found', '사용자 정보를 찾을 수 없습니다');
        return;
      }

      final data = currentUserData.data() as Map<String, dynamic>;
      final referrerApproval = data['referrer_approval'] as List<dynamic>?;

      if (referrerApproval == null || referrerApproval.isEmpty) {
        isLoading = false;
        debugPrint('나를 추천한 친구가 없습니다');
        return;
      }

      debugPrint('나를 추천한 친구 수: ${referrerApproval.length}');

      // 친구 데이터 담을 리스트
      List<Map<String, dynamic>> loadedFriends = [];

      // 각 추천인에 대한 정보 가져오기
      for (final item in referrerApproval) {
        if (item is Map && item.containsKey('uid')) {
          final String friendUid = item['uid'] as String;

          // 해당 uid의 사용자 정보 가져오기
          final friendDoc = await FirebaseFirestore.instance
              .collection('tripfriends_users')
              .doc(friendUid)
              .get();

          if (friendDoc.exists) {
            final friendData = friendDoc.data() as Map<String, dynamic>;

            // reservation 컬렉션의 문서 개수 가져오기
            int reservationCount = 0;

            try {
              final reservationSnapshot = await FirebaseFirestore.instance
                  .collection('tripfriends_users')
                  .doc(friendUid)
                  .collection('reservation')
                  .get();

              reservationCount = reservationSnapshot.docs.length;
              debugPrint('사용자 ${friendData['name']}의 예약 개수: $reservationCount');
            } catch (e) {
              debugPrint('예약 정보 로드 에러: $e');
            }

            loadedFriends.add({
              'id': friendUid,
              'name': friendData['name'] ?? '알 수 없음',
              'photoUrl': friendData['profileImageUrl'],
              'reservationCount': reservationCount,
            });
            debugPrint('친구 정보 로드: ${friendData['name']}, 예약 수: $reservationCount');
          }
        }
      }

      // 예약 개수에 따라 정렬 (많은 순서대로)
      loadedFriends.sort((a, b) =>
          (b['reservationCount'] as int).compareTo(a['reservationCount'] as int));

      friends = loadedFriends;
      debugPrint('로드된 친구 수: ${friends.length}');
      isLoading = false;
    } catch (e) {
      isLoading = false;
      errorMessage = getTranslatedText(
          'error_loading_history',
          '추천받은 친구 목록을 불러오는 중 오류가 발생했습니다'
      );
      debugPrint('친구 목록 로드 에러: $e');
    }
  }

  // 초기화 메서드 - 적립금 관련 메서드 호출 제거
  Future<void> init() async {
    await loadUserData();
    await loadFriendsList();
  }

  // 파트너 코드 복사 기능
  Future<bool> copyPartnerCode() async {
    try {
      await Clipboard.setData(ClipboardData(text: referrerCode));
      return true;
    } catch (e) {
      debugPrint('코드 복사 에러: $e');
      return false;
    }
  }
}