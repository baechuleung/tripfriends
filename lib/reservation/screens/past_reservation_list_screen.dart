import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../controllers/reservation_controller.dart';
import '../widgets/past/past_reservation_header_widget.dart';
import '../widgets/past/past_reservation_card_widget.dart';
import '../../translations/reservation_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class PastReservationListScreen extends StatefulWidget {
  const PastReservationListScreen({Key? key}) : super(key: key);

  @override
  State<PastReservationListScreen> createState() => _PastReservationListScreenState();
}

class _PastReservationListScreenState extends State<PastReservationListScreen> {
  final ReservationController _controller = ReservationController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  DateTime? _parseCompletedTimestamp(String timestamp) {
    try {
      // "2025년 5월 21일 오전 3시 53분 18초 UTC+9" 형식을 파싱
      final regex = RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일\s*(오전|오후)\s*(\d{1,2})시\s*(\d{1,2})분\s*(\d{1,2})초\s*UTC\+9');
      final match = regex.firstMatch(timestamp);

      if (match == null) return null;

      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      final ampm = match.group(4)!;
      int hour = int.parse(match.group(5)!);
      final minute = int.parse(match.group(6)!);
      final second = int.parse(match.group(7)!);

      // 12시간 형식을 24시간 형식으로 변환
      if (ampm == '오후' && hour != 12) {
        hour += 12;
      } else if (ampm == '오전' && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      return null;
    }
  }

  DateTime? _getCompletedTimestamp(Reservation reservation) {
    if (reservation.statusHistory == null) return null;

    for (var history in reservation.statusHistory!) {
      if (history['status'] == 'completed') {
        final timestamp = history['timestamp'];
        if (timestamp != null) {
          // Timestamp 타입인 경우
          if (timestamp is Timestamp) {
            return timestamp.toDate();
          }
          // String 타입인 경우
          else if (timestamp is String) {
            return _parseCompletedTimestamp(timestamp);
          }
        }
      }
    }
    return null;
  }

  List<Reservation> _sortReservationsByCompletedTime(List<Reservation> reservations) {
    final now = DateTime.now();

    reservations.sort((a, b) {
      final timestampA = _getCompletedTimestamp(a);
      final timestampB = _getCompletedTimestamp(b);

      // completed 타임스탬프가 없는 경우 뒤로 밀기
      if (timestampA == null && timestampB == null) return 0;
      if (timestampA == null) return 1;
      if (timestampB == null) return -1;

      // 현재 시간과의 차이 계산 (절댓값)
      final diffA = timestampA.difference(now).abs();
      final diffB = timestampB.difference(now).abs();

      return diffA.compareTo(diffB);
    });

    return reservations;
  }

  Future<void> _onRefresh() async {
    // 단순히 setState를 호출하여 화면을 다시 그리도록 함
    setState(() {});
    // 약간의 지연을 추가하여 사용자가 새로고침을 인지할 수 있도록 함
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF353535),
            size: 20,
          ),
          onPressed: () {
            // MainPage의 홈 탭(인덱스 0)으로 이동
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
                  (route) => false,
            );
          },
        ),
        titleSpacing: 0,
        title: StreamBuilder<List<Reservation>>(
          stream: _controller.getPastReservationsStream(),
          builder: (context, snapshot) {
            final reservationCount = snapshot.hasData ? snapshot.data!.length : 0;

            return Row(
              children: [
                Text(
                  ReservationTranslations.getTranslation('past_reservations', _currentLanguage),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF353535),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF999999),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$reservationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE5E5E5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Reservation>>(
          stream: _controller.getPastReservationsStream(),
          builder: (context, snapshot) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF237AFF),
              child: _buildReservationList(snapshot),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReservationList(AsyncSnapshot<List<Reservation>> snapshot) {
    // 로딩 중이면 로딩 표시
    if (snapshot.connectionState == ConnectionState.waiting) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF237AFF)),
              ),
            ),
          ),
        ],
      );
    }

    // 에러가 있으면 에러 메시지
    if (snapshot.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  ReservationTranslations.getTranslation('loading_error', _currentLanguage),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 데이터가 없으면 안내 메시지
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                ReservationTranslations.getTranslation('no_past_reservations', _currentLanguage),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 데이터가 있으면 목록 표시 (completed 시간순 정렬)
    final reservations = _sortReservationsByCompletedTime(List.from(snapshot.data!));
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return PastReservationCardWidget(
          reservation: reservations[index],
          currentUserId: _auth.currentUser?.uid,
        );
      },
    );
  }
}