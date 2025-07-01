import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../translations/trip_main_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class HorizontalReservationCards extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HorizontalReservationCards({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<HorizontalReservationCards> createState() => _HorizontalReservationCardsState();
}

class _HorizontalReservationCardsState extends State<HorizontalReservationCards> {
  int activeReservationCount = 0;
  int pastReservationCount = 0;
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

    _loadReservationCounts();
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadReservationCounts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final reservationsRef = FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('reservations');

      final activeQuery = await reservationsRef
          .where('status', whereIn: ['in_progress', 'pending'])
          .get();

      final pastQuery = await reservationsRef
          .where('status', isEqualTo: 'completed')
          .get();

      if (mounted) {
        setState(() {
          activeReservationCount = activeQuery.docs.length;
          pastReservationCount = pastQuery.docs.length;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('예약 건수 로드 오류: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReservationCard(
            title: MainTranslations.getTranslation('reservation', _currentLanguage),
            count: isLoading ? '...' : '$activeReservationCount${MainTranslations.getTranslation('count_unit', _currentLanguage)}',
            isLoading: isLoading,
            backgroundColor: const Color(0xFFE6F1FF),
            textColor: const Color(0xFF005AB8),
            iconColor: const Color(0xFF005AB8),
            titleStyle: const TextStyle(
              color: Color(0xFF0059B7),
              fontSize: 14,
              fontFamily: 'Spoqa Han Sans Neo',
              fontWeight: FontWeight.w700,
            ),
            icon: Icons.calendar_month,
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(1);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ReservationCard(
            title: MainTranslations.getTranslation('past_reservation', _currentLanguage),
            count: isLoading ? '...' : '$pastReservationCount${MainTranslations.getTranslation('count_unit', _currentLanguage)}',
            isLoading: isLoading,
            backgroundColor: Colors.white,
            textColor: const Color(0xFF4E5968),
            iconColor: const Color(0xFF4E5968),
            titleStyle: const TextStyle(
              color: Color(0xFF4E5968),
              fontSize: 13,
              fontFamily: 'Spoqa Han Sans Neo',
              fontWeight: FontWeight.w700,
            ),
            icon: Icons.calendar_month,
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(2);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String title;
  final String count;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final TextStyle titleStyle;
  final IconData icon;
  final VoidCallback onTap;

  const _ReservationCard({
    required this.title,
    required this.count,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.titleStyle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 85,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: titleStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}