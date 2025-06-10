import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../translations/reservation_translations.dart';
import '../../../chat/screens/friend_chat_screen.dart';

class ReservationChatButtonWidget extends StatelessWidget {
  final String customerId;
  final String customerName;
  final String? currentUserId;
  final String currentLanguage;
  final String? reservationStatus;

  const ReservationChatButtonWidget({
    Key? key,
    required this.customerId,
    required this.customerName,
    required this.currentUserId,
    required this.currentLanguage,
    this.reservationStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      content: Text(ReservationTranslations.getTranslation('login_required', currentLanguage)),
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
                backgroundColor: const Color(0xFF0059B7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Symbols.forum_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ReservationTranslations.getTranslation('start_chat', currentLanguage),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Spoqa Han Sans Neo',
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