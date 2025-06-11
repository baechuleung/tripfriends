import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final Map<String, dynamic> data;

  Reservation({required this.id, required this.data});

  // 전체 데이터 가져오기
  Map<String, dynamic> getAllData() {
    return data;
  }

  // 특정 필드 존재 여부 확인
  bool hasField(String fieldName) {
    return data.containsKey(fieldName);
  }

  // 동적으로 필드 값 가져오기
  dynamic getField(String fieldName) {
    return data[fieldName];
  }

  // 모든 필드에 대한 getter
  String get reservationNumber => data['reservationNumber'] ?? '';
  String get useDate => data['useDate'] ?? '';
  String get useTime => data['useTime'] ?? '';
  int get useDuration => data['useDuration'] ?? 0;
  String get address => data['location']?['address'] ?? '';
  double get latitude => data['location']?['latitude'] ?? 0.0;
  double get longitude => data['location']?['longitude'] ?? 0.0;
  int get pricePerHour => data['pricePerHour'] ?? 0;
  String get currencySymbol => data['currencySymbol'] ?? '';
  int get personCount => data['personCount'] ?? 0;
  String get customerId => data['userId'] ?? '';
  String get friendsId => data['friends_uid'] ?? '';
  String get status => data['status'] ?? '';
  String get requestNote => data['request_note'] ?? '';
  String get customerName => data['userName'] ?? '고객';
  String get userEmail => data['userEmail'] ?? '';
  String get country => data['country'] ?? '';
  int get depositAmount => data['depositAmount'] ?? 0;
  String get schedule => data['schedule'] ?? '';

  // 추가 필드
  String get currencyCode => data['currencyCode'] ?? '';
  int get additionalPrice => data['currentPriceInfo']?['additionalPrice'] ?? 0;
  int get basePrice => data['currentPriceInfo']?['basePrice'] ?? 0;
  int get totalPriceInfo => data['currentPriceInfo']?['totalPrice'] ?? 0;
  String get usedTime => data['usedTime'] ?? '0';
  bool get isPaymentAgreed => data['isPaymentAgreed'] ?? false;
  bool get isProhibitionAgreed => data['isProhibitionAgreed'] ?? false;
  String get meetingAddress => data['meetingPlace']?['address'] ?? '';
  double get meetingLatitude => data['meetingPlace']?['latitude'] ?? 0.0;
  double get meetingLongitude => data['meetingPlace']?['longitude'] ?? 0.0;
  String get startTime => data['startTime'] ?? '';
  String get requestId => data['requestId'] ?? '';

  // 동의 관련 정보
  Map<String, dynamic> get agreements => data['agreements'] ?? {};
  Map<String, dynamic> get paymentAgreement => data['agreements']?['payment'] ?? {};
  Map<String, dynamic> get prohibitionAgreement => data['agreements']?['prohibition'] ?? {};
  Map<String, dynamic> get reviewAgreement => data['agreements']?['review'] ?? {};

  // 가격 히스토리 정보
  List<Map<String, dynamic>> get priceHistory {
    if (data['priceHistory'] is List) {
      return (data['priceHistory'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  // 목적 정보
  List<String> get purpose {
    if (data['purpose'] is List) {
      return (data['purpose'] as List)
          .map((item) => item.toString())
          .toList();
    }
    return <String>[];
  }

  // 타임스탬프 관련 필드
  Timestamp? get createdAtTimestamp => data['createdAt'] as Timestamp?;
  Timestamp? get updatedAtTimestamp => data['updatedAt'] as Timestamp?;
  Timestamp? get paidAtTimestamp => data['paidAt'] as Timestamp?;
  Timestamp? get completedAtTimestamp => data['completedAt'] as Timestamp?;
  Timestamp? get agreementTimestamp => data['agreementTimestamp'] as Timestamp?;

  // 완료 정보
  Map<String, dynamic> get completionInfo => data['completionInfo'] ?? {};
  int get finalPrice => data['completionInfo']?['finalPrice'] ?? 0;
  String get finalUsedTime => data['completionInfo']?['finalUsedTime'] ?? '';

  String get createdAtFormatted {
    if (data['createdAt'] is Timestamp) {
      return (data['createdAt'] as Timestamp)
          .toDate()
          .toString()
          .substring(0, 16);
    }
    return '날짜 없음';
  }

  String get updatedAtFormatted {
    if (data['updatedAt'] is Timestamp) {
      return (data['updatedAt'] as Timestamp)
          .toDate()
          .toString()
          .substring(0, 16);
    }
    return '날짜 없음';
  }

  String get paidAtFormatted {
    if (data['paidAt'] is Timestamp) {
      return (data['paidAt'] as Timestamp)
          .toDate()
          .toString()
          .substring(0, 16);
    }
    return '날짜 없음';
  }

  String get completedAtFormatted {
    if (data['completedAt'] is Timestamp) {
      return (data['completedAt'] as Timestamp)
          .toDate()
          .toString()
          .substring(0, 16);
    }
    return '날짜 없음';
  }

  List<Map<String, dynamic>> get statusHistory {
    if (data['statusHistory'] is List) {
      return (data['statusHistory'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  // 가공된 데이터
  int get totalPrice => pricePerHour * useDuration;

  // 상태 이력에서 최신 메시지 가져오기
  String get latestStatusMessage {
    if (statusHistory.isNotEmpty) {
      return statusHistory.last['message'] ?? '';
    }
    return '';
  }

  // 위치 정보를 Map으로 가져오기
  Map<String, dynamic> get locationMap {
    return data['location'] ?? {};
  }

  // 리뷰 약속 상태 확인
  bool get isReviewPromised => data['isReviewPromised'] ?? false;
}