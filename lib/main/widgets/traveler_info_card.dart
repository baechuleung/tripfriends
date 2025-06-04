import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../translations/main_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class TravelerInfoCard extends StatefulWidget {
  const TravelerInfoCard({super.key});

  @override
  State<TravelerInfoCard> createState() => _TravelerInfoCardState();
}

class _TravelerInfoCardState extends State<TravelerInfoCard> {
  int completedCount = 0;
  bool isLoading = true;
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();

    // 현재 언어 설정 가져오기
    _currentLanguage = currentCountryCode;

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });

    // 즉시 로딩 시작
    _loadCompletedReservations();
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCompletedReservations() async {
    try {
      debugPrint('🔍 전체 완료된 예약 수를 가져옵니다');

      // Collection Group Query를 사용하여 모든 사용자의 완료된 reservations 조회
      final completedReservationsQuery = await FirebaseFirestore.instance
          .collectionGroup('reservations')
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      final count = completedReservationsQuery.count ?? 0;
      debugPrint('📊 전체 완료된 예약 수: $count');

      if (mounted) {
        setState(() {
          completedCount = count;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 완료된 예약 정보 로드 오류: $e');
      debugPrint('💡 Collection Group Query를 사용하려면 Firebase Console에서 인덱스를 생성해야 합니다');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getCountUnitText() {
    return MainTranslations.getTranslation('count_unit', _currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              MainTranslations.getTranslation('total_completed_reservations', _currentLanguage),
              style: TextStyle(
                color: const Color(0xFF4E5968),
                fontSize: 13,
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: isLoading
                ? Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              ),
            )
                : Text(
              '$completedCount ${_getCountUnitText()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.pink,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}