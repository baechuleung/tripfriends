import 'package:flutter/material.dart';
import '../../../services/translation_service.dart';

class PastReservationHeaderWidget extends StatelessWidget {
  final int count;
  final TranslationService translationService;

  const PastReservationHeaderWidget({
    Key? key,
    required this.count,
    required this.translationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text(
            translationService.get('past_reservations', '지난 예약 내역'),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF353535)
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF999999), // 지난 예약이므로 회색으로 변경
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
}