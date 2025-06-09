import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';
import '../controllers/reservation_controller.dart';
import '../widgets/current/current_reservation_header_widget.dart';
import '../widgets/current/current_reservation_card_widget.dart';
import '../../translations/reservation_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class CurrentReservationListScreen extends StatefulWidget {
  const CurrentReservationListScreen({Key? key}) : super(key: key);

  @override
  State<CurrentReservationListScreen> createState() => _CurrentReservationListScreenState();
}

class _CurrentReservationListScreenState extends State<CurrentReservationListScreen> {
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

  DateTime? _parseReservationDateTime(String useDate, String startTime) {
    try {
      // useDate: "2025년 5월 20일" 형식을 파싱
      final dateRegex = RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일');
      final dateMatch = dateRegex.firstMatch(useDate);

      if (dateMatch == null) return null;

      final year = int.parse(dateMatch.group(1)!);
      final month = int.parse(dateMatch.group(2)!);
      final day = int.parse(dateMatch.group(3)!);

      // startTime: "8:10 AM" 형식을 파싱
      final timeRegex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false);
      final timeMatch = timeRegex.firstMatch(startTime);

      if (timeMatch == null) return null;

      int hour = int.parse(timeMatch.group(1)!);
      final minute = int.parse(timeMatch.group(2)!);
      final ampm = timeMatch.group(3)!.toUpperCase();

      // 12시간 형식을 24시간 형식으로 변환
      if (ampm == 'PM' && hour != 12) {
        hour += 12;
      } else if (ampm == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  List<Reservation> _sortReservationsByDateTime(List<Reservation> reservations) {
    final now = DateTime.now();

    reservations.sort((a, b) {
      final dateTimeA = _parseReservationDateTime(a.useDate, a.startTime);
      final dateTimeB = _parseReservationDateTime(b.useDate, b.startTime);

      // 파싱에 실패한 경우 뒤로 밀기
      if (dateTimeA == null && dateTimeB == null) return 0;
      if (dateTimeA == null) return 1;
      if (dateTimeB == null) return -1;

      // 현재 시간과의 차이 계산 (절댓값)
      final diffA = dateTimeA.difference(now).abs();
      final diffB = dateTimeB.difference(now).abs();

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
          stream: _controller.getCurrentReservationsStream(),
          builder: (context, snapshot) {
            final reservationCount = snapshot.hasData ? snapshot.data!.length : 0;

            return Row(
              children: [
                Text(
                  ReservationTranslations.getTranslation('current_reservations', _currentLanguage),
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
                    color: const Color(0xFF237AFF),
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
          stream: _controller.getCurrentReservationsStream(),
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
                ReservationTranslations.getTranslation('no_reservations', _currentLanguage),
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

    // 데이터가 있으면 목록 표시 (시간순 정렬)
    final reservations = _sortReservationsByDateTime(List.from(snapshot.data!));
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        return CurrentReservationCardWidget(
          reservation: reservations[index],
          currentUserId: _auth.currentUser?.uid,
        );
      },
    );
  }
}