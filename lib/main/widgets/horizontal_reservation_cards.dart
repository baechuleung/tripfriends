import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _loadReservationCounts();
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
            title: '예약',
            count: isLoading ? '...' : '$activeReservationCount건',
            isNew: true,
            isLoading: isLoading,
            backgroundColor: Colors.blue[50]!,
            textColor: Colors.blue,
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
            title: '지난예약',
            count: isLoading ? '...' : '$pastReservationCount건',
            isNew: false,
            isLoading: isLoading,
            backgroundColor: Colors.pink[50]!,
            textColor: Colors.pink,
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
  final bool isNew;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ReservationCard({
    required this.title,
    required this.count,
    required this.isNew,
    required this.isLoading,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}