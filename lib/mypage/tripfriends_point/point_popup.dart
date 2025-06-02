import 'package:flutter/material.dart';
import '../../services/translation_service.dart';

class PointPopup extends StatelessWidget {
  final int points;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final TranslationService _translationService = TranslationService();

  PointPopup({
    Key? key,
    required this.points,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 16),
          // LANK UP! 타이틀
          Text(
            _translationService.get('rank_up', 'LANK UP!'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF353535),
            ),
          ),
          const SizedBox(height: 24),
          // 500 P를 강조
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$points P',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6900),
                  ),
                ),
                TextSpan(
                  text: _translationService.get('point_usage_question', '를\n사용하시겠습니까?'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF767676),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 취소 및 확인 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 취소 버튼
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _translationService.get('cancel', '취소'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6900),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 확인 버튼
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _translationService.get('confirm', '확인'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3182F6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}