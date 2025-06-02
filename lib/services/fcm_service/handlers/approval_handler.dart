// lib/services/fcm_service/handlers/approval_handler.dart
import 'package:flutter/material.dart';
import '../../../main_page.dart';  // MainPage import
import 'message_handler.dart';  // navigatorKey 접근용

class ApprovalHandler {
  // 승인 사유 업데이트 알림 처리
  static void handleApprovalUpdate(Map<String, dynamic> data) {
    String? userId = data['user_id'];
    String? approvalReason = data['approval_reason'];

    print('📋 승인 사유 업데이트 알림 처리: userId=$userId, reason=$approvalReason');

    // 현재 가능한 상태인지 확인 (내비게이터 상태 체크)
    if (navigatorKey.currentState == null) {
      print('⚠️ 내비게이터 상태가 없습니다. 나중에 다시 시도합니다.');
      return;
    }

    // 약간의 지연을 주어 앱이 완전히 초기화되도록 함
    Future.delayed(const Duration(milliseconds: 500), () {
      // MainPage로 이동하면서 MyPage 탭(인덱스 3)을 선택하도록 파라미터 전달
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainPage(initialIndex: 3), // MyPage는 4번째 탭 (인덱스 3)
        ),
            (route) => false,  // 모든 라우트 제거
      );

      print('📱 메인 화면으로 이동 후 MyPage 탭 선택 완료');
    });
  }

  // 승인 사유 관련 추가 처리 로직
  static void processApprovalUpdate(Map<String, dynamic> data) {
    // 승인 사유 업데이트에 대한 추가 처리 로직
    // 예: 로컬 데이터 업데이트, 알림 배지 업데이트 등
    print('📋 승인 사유 업데이트 처리 중: ${data['approval_reason']}');
  }
}