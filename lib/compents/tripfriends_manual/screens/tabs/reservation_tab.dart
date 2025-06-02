import 'package:flutter/material.dart';
import '../../../../services/translation_service.dart';
import '../../../../main.dart'; // 올바른 import 경로

class ReservationTab extends StatefulWidget {
  final TranslationService translationService;

  const ReservationTab({
    Key? key,
    required this.translationService,
  }) : super(key: key);

  @override
  State<ReservationTab> createState() => _ReservationTabState();
}

class _ReservationTabState extends State<ReservationTab> {
  String _countryCode = currentCountryCode;

  @override
  void initState() {
    super.initState();
    // 언어 변경 이벤트 구독
    languageChangeController.stream.listen((String newCode) {
      if (mounted) setState(() => _countryCode = newCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 국가 코드에 맞는 이미지 로드
            Image.asset(
              'assets/manual/Reservation/$_countryCode.png',
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                // 해당 국가 코드의 이미지가 없는 경우 기본값(KR)으로 대체
                return Image.asset(
                  'assets/manual/Reservation/KR.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // 기본 이미지도 없는 경우 오류 메시지 표시
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              widget.translationService.get(
                                  'manual_image_not_found',
                                  '매뉴얼 이미지를 찾을 수 없습니다.'
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}