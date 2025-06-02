// auth_point.dart

class AuthPoint {
  // 인증 포인트 정보
  static const Map<String, num> points = {
    "KRW": 10000,
    "JPY": 1000,
    "VND": 18000,
    "THB": 300,
    "TWD": 300,
    "CNY": 50,
    "HKD": 70,
    "PHP": 500,
    "USD": 10,
    "SGD": 12
  };

  // 추천 포인트 정보
  static const Map<String, num> recommendedPoints = {
    "KRW": 5000,
    "JPY": 500,
    "VND": 18000,
    "THB": 150,
    "TWD": 150,
    "CNY": 25,
    "HKD": 35,
    "PHP": 250,
    "USD": 5,
    "SGD": 6
  };

  // 미디어 업로드 보상 정보
  static const Map<String, num> mediaUploadRewards = {
    "KRW": 10000,
    "JPY": 500,
    "VND": 54000,
    "THB": 150,
    "TWD": 150,
    "CNY": 25,
    "HKD": 35,
    "PHP": 250,
    "USD": 5,
    "SGD": 6
  };

  // 인증 포인트 가져오기
  static num getPoint(String currencyCode) {
    return points[currencyCode] ?? 0;
  }

  // 추천 포인트 가져오기
  static num getRecommendedPoint(String currencyCode) {
    return recommendedPoints[currencyCode] ?? 0;
  }

  // 미디어 업로드 보상 가져오기
  static num getMediaUploadReward(String currencyCode) {
    return mediaUploadRewards[currencyCode] ?? 0;
  }
}