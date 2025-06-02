import 'package:flutter/material.dart';
import '../../services/translation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'point_popup.dart'; // 팝업 위젯 임포트

class PointItem extends StatelessWidget {
  final String title;
  final int currentPoint;
  final String rankUpText;
  final int rankUpPoint;

  const PointItem({
    Key? key,
    required this.title,
    required this.currentPoint,
    required this.rankUpText,
    required this.rankUpPoint,
  }) : super(key: key);

  // 추천 프렌즈 활성화 함수
  Future<void> _activateRecommendation(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar(context, TranslationService().get('login_required', '로그인이 필요합니다.'));
        return;
      }

      // 사용자의 현재 정보 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showErrorSnackBar(context, TranslationService().get('user_not_found', '사용자 정보를 찾을 수 없습니다.'));
        return;
      }

      final userData = userDoc.data();
      if (userData == null) {
        _showErrorSnackBar(context, TranslationService().get('no_user_data', '사용자 데이터가 없습니다.'));
        return;
      }

      // 현재 포인트 확인
      final currentUserPoint = userData['point'] ?? 0;
      if (currentUserPoint < 500) {
        _showErrorSnackBar(context, TranslationService().get('insufficient_points', '포인트가 부족합니다.'));
        return;
      }

      // 트랜잭션으로 포인트 차감 및 recommendation 필드 추가
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 필드 업데이트
        transaction.update(userDoc.reference, {
          'point': FieldValue.increment(-500), // 500 포인트 차감
          'recommendation': {
            'status': true,
            'activatedAt': FieldValue.serverTimestamp(), // 서버 타임스탬프 사용
          }
        });
      });

      // 성공 메시지 표시
      _showSuccessSnackBar(context, TranslationService().get('recommendation_activated', '추천 프렌즈가 활성화되었습니다!'));
    } catch (e) {
      _showErrorSnackBar(context, TranslationService().get('error_occurred', '오류가 발생했습니다: ') + e.toString());
    }
  }

  // 사용 확인 팝업 표시
  void _showConfirmationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointPopup(
          points: rankUpPoint,
          onConfirm: () {
            Navigator.of(context).pop(); // 팝업 닫기
            _activateRecommendation(context); // 확인 시 추천 프렌즈 활성화
          },
          onCancel: () {
            Navigator.of(context).pop(); // 팝업 닫기
          },
        );
      },
    );
  }

  // 성공 스낵바 표시
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 오류 스낵바 표시
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TranslationService 인스턴스화
    final TranslationService _translationService = TranslationService();

    // 포인트 형식 지정 (천 단위 구분자 추가)
    final formattedPoint = currentPoint.toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    // 포인트가 500 이상인지 확인
    final bool isRankUpAvailable = currentPoint >= rankUpPoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 추천 프렌즈 타이틀과 도움말 아이콘
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 16 추가
                child: Row(
                  children: [
                    Text(
                      _translationService.get('recommended_friends', '추천 프렌즈'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF353535),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF767676),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 포인트 표시 영역
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 마진 16 추가
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // 그림자 제거
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title, // 이미 번역된 'MY POINT' 텍스트
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF353535),
                      ),
                    ),
                    Text(
                      '$formattedPoint P',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6900),
                      ),
                    ),
                  ],
                ),
              ),

              // LANK UP! 배너 - 포인트에 따라 활성화/비활성화
              const SizedBox(height: 16),
              if (isRankUpAvailable)
              // 활성화 상태 (노란색 배경)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 마진 16 추가
                  child: GestureDetector(
                    onTap: () => _showConfirmationPopup(context), // 팝업 표시로 변경
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3DE), // 연한 노란색 배경
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$rankUpText ${rankUpPoint} P ${_translationService.get('p_usage', '사용')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6900), // 주황색 텍스트
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
              // 비활성화 상태 (회색 배경)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 마진 16 추가
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // 연한 회색 배경
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$rankUpText ${rankUpPoint} ${_translationService.get('p_usage', '사용')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9E9E9E), // 회색 텍스트
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}