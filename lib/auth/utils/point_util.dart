// utils/point_util.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/auth_point.dart'; // auth_point.dart 파일 import

/// 적립금 관련 유틸리티 클래스
class PointUtil {
  /// 통화코드로 적립금 금액 가져오기
  static Future<int> getPointAmountByCurrencyCode(String currencyCode) async {
    print('💰 통화코드 $currencyCode로 적립금 금액 조회 시도');

    // AuthPoint 클래스에서 직접 값을 가져옴
    final num amount = AuthPoint.getPoint(currencyCode);

    if (amount > 0) {
      print('💰 통화코드 $currencyCode에 대한 적립금 금액 찾음: $amount');
      return amount.toInt();
    } else {
      print('⚠️ 통화코드 $currencyCode에 대한 적립금 정보 없음, 기본값(KRW) 사용: ${AuthPoint.getPoint("KRW")}');
      return AuthPoint.getPoint("KRW").toInt();
    }
  }

  /// 통화코드로 추천 받은 회원 적립금 금액 가져오기
  static Future<int> getRecommendedPointAmountByCurrencyCode(String currencyCode) async {
    print('💰 통화코드 $currencyCode로 추천 적립금 금액 조회 시도');

    // AuthPoint 클래스에서 직접 값을 가져옴
    final num amount = AuthPoint.getRecommendedPoint(currencyCode);

    if (amount > 0) {
      print('💰 통화코드 $currencyCode에 대한 추천 적립금 금액 찾음: $amount');
      return amount.toInt();
    } else {
      print('⚠️ 통화코드 $currencyCode에 대한 추천 적립금 정보 없음, 기본값(KRW) 사용: ${AuthPoint.getRecommendedPoint("KRW")}');
      return AuthPoint.getRecommendedPoint("KRW").toInt();
    }
  }

  /// 통화코드로 영상 업로드 보상 금액 가져오기
  static Future<int> getVideoUploadRewardByCurrencyCode(String currencyCode) async {
    print('💰 통화코드 $currencyCode로 영상 업로드 보상 금액 조회 시도');

    // AuthPoint 클래스에서 직접 값을 가져옴
    final num amount = AuthPoint.getMediaUploadReward(currencyCode);

    if (amount > 0) {
      print('💰 통화코드 $currencyCode에 대한 영상 업로드 보상 금액 찾음: $amount');
      return amount.toInt();
    } else {
      print('⚠️ 통화코드 $currencyCode에 대한 영상 업로드 보상 정보 없음, 기본값(KRW) 사용: ${AuthPoint.getMediaUploadReward("KRW")}');
      return AuthPoint.getMediaUploadReward("KRW").toInt();
    }
  }

  /// 사용자가 영상 업로드 보상을 이미 받았는지 확인
  static Future<bool> hasReceivedVideoUploadReward(String uid) async {
    try {
      // Firestore 인스턴스
      final firestore = FirebaseFirestore.instance;

      // 해당 유저의 balance_history에서 video_upload 타입의 보상 기록 확인
      final balanceRef = firestore
          .collection("tripfriends_users")
          .doc(uid)
          .collection("balance_history")
          .where("source", isEqualTo: "video_upload")
          .limit(1);

      final snapshot = await balanceRef.get();

      // 기록이 하나라도 있으면 이미 보상을 받은 것
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ 영상 업로드 보상 확인 중 오류 발생: $e');
      return false; // 에러 발생 시 기본값은 false (보상 받지 않음)
    }
  }

  /// 추천인에게 적립금 추가 (추천한 사람 = 기존 회원 = referrerUid)
  static Future<void> addReferralPoints({
    required String referrerUid,
    required String referredUserName,
    required String currencyCode
  }) async {
    try {
      print('💰 추천인(기존 회원) 적립금 추가 시작 - UID: $referrerUid, 통화코드: $currencyCode');

      // Firestore 인스턴스
      final firestore = FirebaseFirestore.instance;

      // 추천인 적립금 금액 계산 - 해당 통화 코드의 추천 적립금 금액 사용
      final int referralAmount = await getRecommendedPointAmountByCurrencyCode(currencyCode);
      print('💰 추천인 적립금 금액: $currencyCode - $referralAmount');

      // Firestore에 적립금 내역 추가 - 추천인의 balance_history에 추가
      final balanceRef = firestore
          .collection("tripfriends_users")
          .doc(referrerUid)
          .collection("balance_history");

      await balanceRef.add({
        "amount": referralAmount,
        "type": "earn",
        "source": "referral",
        "description": "$referredUserName 회원 추천 적립금",
        "created_at": FieldValue.serverTimestamp(),
      });

      // 추천인 문서에 적립금 총액 업데이트
      await firestore.collection("tripfriends_users").doc(referrerUid).update({
        "point": FieldValue.increment(referralAmount),
      });

      print('✅ 추천인 적립금 추가 완료: $referralAmount');
    } catch (e) {
      print('❌ 추천인 적립금 추가 실패: $e');
    }
  }

  /// 영상 업로드 보상 적립금 추가
  static Future<void> addVideoUploadPoints(String uid, String currencyCode) async {
    try {
      print('💰 영상 업로드 보상 적립금 추가 시작 - UID: $uid, 통화코드: $currencyCode');

      // Firestore 인스턴스
      final firestore = FirebaseFirestore.instance;

      // 적립금 금액 가져오기
      final int amount = await getVideoUploadRewardByCurrencyCode(currencyCode);

      print('💰 영상 업로드 보상 정보: $amount');

      // Firestore에 적립금 내역 추가
      final balanceRef = firestore
          .collection("tripfriends_users")
          .doc(uid)
          .collection("balance_history");

      await balanceRef.add({
        "amount": amount,
        "type": "earn", // 적립 유형
        "source": "video_upload", // 적립 출처 - 영상 업로드
        "description": "소개 영상 업로드 보상", // 설명
        "created_at": FieldValue.serverTimestamp(),
      });

      // 사용자 문서에 적립금 총액 업데이트
      await firestore.collection("tripfriends_users").doc(uid).update({
        "point": FieldValue.increment(amount), // 총 적립금 증가
      });

      print('✅ 영상 업로드 보상 적립금 추가 완료: $amount');
    } catch (e) {
      print('❌ 영상 업로드 보상 적립금 추가 실패: $e');
      // 적립금 추가 실패는 업로드 프로세스를 중단하지 않음
    }
  }

  /// 상세 정보 완성 적립금 추가 (자기소개 300자 이상 작성시)
  static Future<void> addProfileCompletionPoints(String uid, String currencyCode) async {
    try {
      print('💰 프로필 완성 적립금 추가 시작 - UID: $uid, 통화코드: $currencyCode');

      // Firestore 인스턴스
      final firestore = FirebaseFirestore.instance;

      // 사용자 문서에서 실제 currencyCode 가져오기
      final userDoc = await firestore.collection("tripfriends_users").doc(uid).get();
      String actualCurrencyCode = currencyCode; // 기본값

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['currencyCode'] != null) {
          actualCurrencyCode = userData['currencyCode'];
          print('💰 사용자 문서에서 실제 통화코드 확인: $actualCurrencyCode');
        }
      }

      // 이미 프로필 완성 포인트를 받았는지 확인
      final checkQuery = firestore
          .collection("tripfriends_users")
          .doc(uid)
          .collection("balance_history")
          .where("source", isEqualTo: "profile_completion")
          .limit(1);

      final snapshot = await checkQuery.get();
      if (snapshot.docs.isNotEmpty) {
        print('⚠️ 이미 프로필 완성 포인트를 받은 사용자입니다.');
        return;
      }

      // 실제 통화코드로 적립금 금액 가져오기
      final int amount = await getPointAmountByCurrencyCode(actualCurrencyCode);
      print('💰 프로필 완성 적립금 정보: $amount (통화: $actualCurrencyCode)');

      // Firestore에 적립금 내역 추가
      final balanceRef = firestore
          .collection("tripfriends_users")
          .doc(uid)
          .collection("balance_history");

      await balanceRef.add({
        "amount": amount,
        "type": "earn",
        "source": "profile_completion",
        "description": "프로필 상세 정보 작성 적립금",
        "created_at": FieldValue.serverTimestamp(),
      });

      // 사용자 문서에 적립금 총액 업데이트
      await firestore.collection("tripfriends_users").doc(uid).update({
        "point": FieldValue.increment(amount),
      });

      print('✅ 프로필 완성 적립금 추가 완료: $amount (통화: $actualCurrencyCode)');
    } catch (e) {
      print('❌ 프로필 완성 적립금 추가 실패: $e');
    }
  }
}