// lib/services/fcm_service/handlers/match_handler.dart

class MatchHandler {
  static void handleMatchRequest(Map<String, dynamic> data) {
    String? matchRequestId = data['match_request_id'];
    if (matchRequestId != null) {
      // 매치 요청 상세 화면으로 이동 로직
      print('🔍 매치 요청 상세로 이동: $matchRequestId');
      // TODO: Navigator를 통한 화면 전환 로직 추가
    }
  }

  static void processMatchRequest(Map<String, dynamic> data) {
    // 매치 요청에 대한 추가 처리 로직
    // 예: 매치 데이터 사전 로드, 알림 배지 업데이트 등
    print('🔍 매치 요청 처리 중: ${data['match_request_id']}');
  }
}