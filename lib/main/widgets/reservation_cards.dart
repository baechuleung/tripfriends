import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationCards extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const ReservationCards({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<ReservationCards> createState() => _ReservationCardsState();
}

class _ReservationCardsState extends State<ReservationCards> {
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

      // 예약 컬렉션 참조
      final reservationsRef = FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .collection('reservations');

      // 진행중/대기중 예약 카운트 (in_progress, pending)
      final activeQuery = await reservationsRef
          .where('status', whereIn: ['in_progress', 'pending'])
          .get();

      // 완료된 예약 카운트 (completed)
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
    return Column(
      children: [
        // 예약 카드
        _ReservationCard(
          title: '예약',
          count: isLoading ? '...' : '$activeReservationCount건',
          icon: Icons.calendar_today,
          isLoading: isLoading,
          onTap: () {
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(1);
            }
          },
        ),
        const SizedBox(height: 12),
        // 지난예약 카드
        _ReservationCard(
          title: '지난예약',
          count: isLoading ? '...' : '$pastReservationCount건',
          icon: Icons.history,
          isLoading: isLoading,
          onTap: () {
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(2);
            }
          },
        ),
      ],
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _ReservationCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  )
                else
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
              ],
            ),
            Icon(icon, color: Colors.purple, size: 24),
          ],
        ),
      ),
    );
  }
}