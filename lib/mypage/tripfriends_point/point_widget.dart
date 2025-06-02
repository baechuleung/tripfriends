import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/translation_service.dart';
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
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    _initTranslations();
    initUserStream();
  }

  Future<void> _initTranslations() async {
    await _translationService.init();
    if (_mounted) {
      setState(() {});
    }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initTranslations();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 파라미터로 값이 제공된 경우 사용
    if (widget.currentPoint != null) {
      return PointItem(
        title: _translationService.get('my_point', 'MY POINT'),
        currentPoint: widget.currentPoint!,
        rankUpText: _translationService.get('rank_up', 'LANK UP!'),
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
          return Center(child: Text(_translationService.get('error_occurred', '오류가 발생했습니다: ${snapshot.error}')));
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
          title: _translationService.get('my_point', 'MY POINT'),
          currentPoint: currentPoint,
          rankUpText: _translationService.get('rank_up', 'LANK UP!'),
          rankUpPoint: 500,
        );
      },
    );
  }
}