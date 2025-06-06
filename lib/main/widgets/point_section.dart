import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../translations/main_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';
import '../../mypage/withdrawal/balance_history_page.dart';
import '../../mypage/withdrawal/withdrawal_page.dart';
import '../../services/translation_service.dart';

class PointSection extends StatefulWidget {
  const PointSection({super.key});

  @override
  State<PointSection> createState() => _PointSectionState();
}

class _PointSectionState extends State<PointSection> {
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;
  late Stream<DocumentSnapshot> _userStream;

  // 사용자 정보
  String currencySymbol = '₩';
  String currencyCode = 'KRW';
  String userCountry = 'KR';  // 사용자 국가 코드 추가

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

    // 사용자 스트림 초기화
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStream = FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .snapshots();
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  // 사용자 데이터 로드
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userData = await FirebaseFirestore.instance
          .collection('tripfriends_users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            currencySymbol = data['currencySymbol'] ?? '₩';
            currencyCode = data['currencyCode'] ?? 'KRW';
            userCountry = data['nationality'] ?? 'KR';  // 사용자 국가 정보 가져오기
          });
        }
      }
    } catch (e) {
      debugPrint('사용자 데이터 로드 에러: $e');
    }
  }

  // 포인트 포맷팅
  String formatPoint(dynamic point) {
    try {
      final numericPoint = point is int ? point : int.parse(point.toString());
      return numericPoint.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},'
      );
    } catch (e) {
      return point.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox(); // 로그인되지 않은 경우 아무것도 표시하지 않음
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${MainTranslations.getTranslation('error_occurred', _currentLanguage)}: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 134,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return const SizedBox();
        }

        // 포인트 정보 가져오기
        final currentPoint = data['point'] ?? 0;
        final formattedPoint = formatPoint(currentPoint);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    MainTranslations.getTranslation('my_points', _currentLanguage),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$currencySymbol $formattedPoint',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                MainTranslations.getTranslation('minimum_withdrawal', _currentLanguage),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TranslationService 인스턴스 생성
                        final translationService = TranslationService();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BalanceHistoryPage(
                              translationService: translationService,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            MainTranslations.getTranslation('points_history', _currentLanguage),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TranslationService 인스턴스 생성
                        final translationService = TranslationService();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WithdrawalPage(
                              translationService: translationService,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            MainTranslations.getTranslation('request_settlement', _currentLanguage),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}