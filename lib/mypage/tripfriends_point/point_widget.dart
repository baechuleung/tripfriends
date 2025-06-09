import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode
import 'point_item.dart';

class PointWidget extends StatefulWidget {
  final int? currentPoint;

  const PointWidget({
    Key? key,
    this.currentPoint,
  }) : super(key: key);

  @override
  State<PointWidget> createState() => _PointWidgetState();
}

class _PointWidgetState extends State<PointWidget> {
  bool _mounted = true;
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    initUserStream();
  }

  void initUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStream = FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = currentCountryCode.toUpperCase();

    // 파라미터로 값이 제공된 경우 사용
    if (widget.currentPoint != null) {
      return PointItem(
        title: MypageTranslations.getTranslation('my_point', language),
        currentPoint: widget.currentPoint!,
        rankUpText: MypageTranslations.getTranslation('rank_up', language),
        rankUpPoint: 500,
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox(); // 로그인되지 않은 경우 아무것도 표시하지 않음
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
                MypageTranslations.getTranslation('error_occurred', language) + ': ${snapshot.error}'
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return const SizedBox();
        }

        // 포인트 정보 가져오기
        final currentPoint = data['point'] ?? 0;

        // PointItem 위젯으로 UI 구성
        return PointItem(
          title: MypageTranslations.getTranslation('my_point', language),
          currentPoint: currentPoint,
          rankUpText: MypageTranslations.getTranslation('rank_up', language),
          rankUpPoint: 500,
        );
      },
    );
  }
}