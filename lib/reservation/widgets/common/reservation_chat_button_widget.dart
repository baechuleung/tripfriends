import 'package:flutter/material.dart';
import '../../../services/translation_service.dart';
import '../../../chat/screens/friend_chat_screen.dart';

class ReservationChatButtonWidget extends StatelessWidget {
  final String customerId;
  final String customerName;
  final String? currentUserId;
  final TranslationService translationService;
  final String? reservationStatus; // 예약 상태 추가

  const ReservationChatButtonWidget({
    Key? key,
    required this.customerId,
    required this.customerName,
    required this.currentUserId,
    required this.translationService,
    this.reservationStatus, // 예약 상태 파라미터 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = translationService;
    // 버튼 색상 설정 - pending이 아닌 경우 3182F6 색상 사용
    final bool isPending = reservationStatus == 'pending';
    final Color buttonBackgroundColor = isPending ? const Color(0xFFE8F2FF) : const Color(0xFF3182F6);
    final Color buttonTextColor = isPending ? const Color(0xFF237AFF) : Colors.white;
    final Color buttonBorderColor = isPending ? const Color(0xFF237AFF).withOpacity(0.3) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // 채팅하기 버튼 (전체 폭 차지)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.get('login_required', '로그인이 필요합니다')),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // 디버그 정보 출력
                print('채팅 화면으로 이동: customerId=$customerId, customerName=$customerName');

                // 채팅 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      friendsId: currentUserId!,
                      customerId: customerId,
                      customerName: customerName,
                      customerImage: null,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonTextColor,
                minimumSize: const Size(double.infinity, 48), // 버튼 높이 증가
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: buttonBorderColor),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 20, // 아이콘 크기 증가
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.get('start_chat', '채팅하기'),
                    style: const TextStyle(
                      fontSize: 16, // 글자 크기 증가
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}