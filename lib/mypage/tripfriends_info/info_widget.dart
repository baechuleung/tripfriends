import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../translations/mypage_translations.dart';
import '../../main.dart'; // currentCountryCode
import 'info_service.dart';
import 'info_ui_components.dart';

class InfoWidget extends StatefulWidget {
  final Map<String, dynamic>? Data;
  final int? basePrice;
  final String? currencySymbol;

  const InfoWidget({
    Key? key,
    this.Data,
    this.basePrice,
    this.currencySymbol,
  }) : super(key: key);

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  bool _mounted = true;
  final InfoService _infoService = InfoService();
  Stream<DocumentSnapshot>? _userStream;

  @override
  void initState() {
    super.initState();
    _initUserStream();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _initUserStream() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userStream = FirebaseFirestore.instance
            .collection('tripfriends_users')
            .doc(user.uid)
            .snapshots();
      }
    } catch (e) {
      debugPrint('Error initializing user stream: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 파라미터로 제공된 데이터 사용
    if (widget.Data != null) {
      final int price = widget.basePrice ?? 10000;
      final String currencySymbol = widget.currencySymbol ?? '₩';
      return InfoUIComponents.buildInfoLayout(
        context: context,
        data: widget.Data!,
        price: price,
        currencySymbol: currencySymbol,
      );
    }

    // 2. 로그인 여부 및 스트림 확인
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _userStream == null) {
      return const SizedBox();
    }

    // 3. Firestore에서 데이터 가져오기
    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        final language = currentCountryCode.toUpperCase();

        // 에러 처리
        if (snapshot.hasError) {
          return Center(child: Text(MypageTranslations.getTranslation(
              'error_occurred',
              language
          ) + ': ${snapshot.error}'));
        }

        // 로딩 처리
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 데이터 없음 처리
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        // 문서 데이터 처리
        final data = snapshot.data!.data();
        if (data == null || data is! Map<String, dynamic>) {
          return const SizedBox();
        }

        // 데이터 파싱
        final Map<String, dynamic> parsedData = _infoService.parseUserData(data);
        final int price = _infoService.getPriceFromData(data);
        final String currencySymbol = _infoService.getCurrencyFromData(data);

        // UI 구성
        return InfoUIComponents.buildInfoLayout(
          context: context,
          data: parsedData,
          price: price,
          currencySymbol: currencySymbol,
        );
      },
    );
  }
}