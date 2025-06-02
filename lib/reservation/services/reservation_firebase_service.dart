import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';

class ReservationFirebaseService {
  static final ReservationFirebaseService _instance = ReservationFirebaseService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory ReservationFirebaseService() {
    return _instance;
  }

  ReservationFirebaseService._internal();

  String? get currentUserId => _auth.currentUser?.uid;

  // 현재 예약 목록 가져오기 (in_progress 또는 pending 상태인 항목)
  Stream<QuerySnapshot> getCurrentReservationsStream() {
    // 현재 사용자 정보 확인
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return _firestore
          .collection('empty_collection_for_no_user')
          .snapshots();
    }

    // 로그인 사용자의 예약 데이터 중 in_progress 또는 pending 상태인 항목만 찾기
    return _firestore
        .collection('tripfriends_users')
        .doc(currentUser.uid)
        .collection('reservations')
        .where('status', whereIn: ['in_progress', 'pending'])
        .snapshots();
  }

  // 지난 예약 목록 가져오기 (completed 상태인 항목)
  Stream<QuerySnapshot> getPastReservationsStream() {
    // 현재 사용자 정보 확인
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return _firestore
          .collection('empty_collection_for_no_user')
          .snapshots();
    }

    // 로그인 사용자의 예약 데이터 중 completed 상태인 항목만 찾기
    return _firestore
        .collection('tripfriends_users')
        .doc(currentUser.uid)
        .collection('reservations')
        .where('status', isEqualTo: 'completed')
        .snapshots();
  }
}