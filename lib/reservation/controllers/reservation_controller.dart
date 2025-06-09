import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/reservation_firebase_service.dart';

class ReservationController {
  final ReservationFirebaseService _firebaseService = ReservationFirebaseService();

  // 현재(결제 완료된) 예약 목록 스트림
  Stream<List<Reservation>> getCurrentReservationsStream() {
    return _firebaseService.getCurrentReservationsStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation(
          id: doc.id,
          data: doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // 지난 예약 목록 스트림 
  Stream<List<Reservation>> getPastReservationsStream() {
    return _firebaseService.getPastReservationsStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation(
          id: doc.id,
          data: doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // 종료 시간 계산
  String calculateEndTime(String startTime, int duration) {
    try {
      final format = DateFormat('HH:mm');
      final time = format.parse(startTime);
      final endTime = time.add(Duration(hours: duration));
      return format.format(endTime);
    } catch (e) {
      return '';
    }
  }

  // 예약 정보 표시용 포맷 메소드
  String formatMeetingInfo(String date, String time, String location) {
    return "$date $time, $location";
  }

  // 사용 시간 포맷 메소드
  String formatUsedTime(String usedTime) {
    return usedTime;
  }

  // 요일 표시 메소드
  String getDayOfWeek(String date) {
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      final dayOfWeek = DateFormat('E').format(parsedDate);
      return dayOfWeek;
    } catch (e) {
      return '';
    }
  }

  // 금액 포맷 메소드
  String formatPrice(int price, String currencySymbol) {
    final formatter = NumberFormat('#,###');
    return "$currencySymbol ${formatter.format(price)}";
  }
}