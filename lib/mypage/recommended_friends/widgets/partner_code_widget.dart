import 'package:flutter/material.dart';
import '../recommended_friends_controller.dart';

class PartnerCodeWidget extends StatelessWidget {
  final RecommendedFriendsController controller;

  const PartnerCodeWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                controller.getTranslatedText('partner_code', '파트너 코드'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Text(
                ' : ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                controller.referrerCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final success = await controller.copyPartnerCode();
              // 복사 완료 메시지 표시
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.getTranslatedText('code_copied', '코드가 복사되었습니다'),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4169E1),
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 36),
            ),
            child: Text(
              controller.getTranslatedText('copy', '복사'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}