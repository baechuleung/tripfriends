import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../translations/location_mapper.dart';
import '../../translations/main_translations.dart';
import '../../main.dart' show currentCountryCode, languageChangeController;

class ReservationInfoCard extends StatefulWidget {
  const ReservationInfoCard({super.key});

  @override
  State<ReservationInfoCard> createState() => _ReservationInfoCardState();
}

class _ReservationInfoCardState extends State<ReservationInfoCard> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> reservations = [];
  Map<String, String> friendNames = {};
  bool isLoading = true;
  int currentIndex = 0;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  // TravelerInfoCard에서 가져온 변수
  int completedCount = 0;
  bool isLoadingCompleted = true;

  // 카운터 애니메이션을 위한 변수
  int _displayedCount = 0;
  Timer? _countTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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

    _loadReservations();
    _loadCompletedReservations();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countTimer?.cancel();
    _animationController.dispose();
    _languageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCompletedReservations() async {
    try {
      debugPrint('🔍 전체 완료된 예약 수를 가져옵니다');

      // Collection Group Query를 사용하여 모든 사용자의 완료된 reservations 조회
      final completedReservationsQuery = await FirebaseFirestore.instance
          .collectionGroup('reservations')
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      final count = completedReservationsQuery.count ?? 0;
      debugPrint('📊 전체 완료된 예약 수: $count');

      if (mounted) {
        setState(() {
          completedCount = count;
          isLoadingCompleted = false;
        });

        // 카운터 애니메이션 시작
        _startCounterAnimation();
      }
    } catch (e) {
      debugPrint('❌ 완료된 예약 정보 로드 오류: $e');
      debugPrint('💡 Collection Group Query를 사용하려면 Firebase Console에서 인덱스를 생성해야 합니다');
      if (mounted) {
        setState(() {
          isLoadingCompleted = false;
        });
      }
    }
  }

  Future<void> _loadReservations() async {
    try {
      debugPrint('🔍 Collection Group Query로 전체 예약 정보를 가져옵니다');

      // Collection Group Query를 사용하여 모든 사용자의 reservations를 한번에 조회
      final allReservationsQuery = await FirebaseFirestore.instance
          .collectionGroup('reservations')
          .where('status', whereIn: ['in_progress', 'pending'])
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('📊 전체 진행중/대기중 예약 수: ${allReservationsQuery.docs.length}');

      if (allReservationsQuery.docs.isNotEmpty) {
        // 예약 데이터와 소유자 ID 매핑
        List<Map<String, dynamic>> allReservations = [];
        Set<String> friendUserIds = {};

        for (var doc in allReservationsQuery.docs) {
          final data = doc.data();
          // 문서 경로에서 소유자 ID 추출
          final pathSegments = doc.reference.path.split('/');
          final ownerId = pathSegments[1]; // tripfriends_users/[userId]/reservations/[docId]

          data['ownerId'] = ownerId;
          data['reservationId'] = doc.id;

          // 디버그: 각 예약 정보 출력
          debugPrint('📄 예약: owner=${ownerId}, status=${data['status']}, location=${data['location']}, friendUserId=${data['friendUserId']}');

          allReservations.add(data);

          // 프렌즈 ID 수집
          if (data['friendUserId'] != null) {
            friendUserIds.add(data['friendUserId']);
          }
        }

        // 프렌즈 정보 일괄 조회
        final Map<String, String> names = {};
        for (String friendUserId in friendUserIds) {
          debugPrint('🔍 프렌즈 정보 조회: $friendUserId');
          try {
            final friendDoc = await FirebaseFirestore.instance
                .collection('tripfriends_users')
                .doc(friendUserId)
                .get();

            if (friendDoc.exists) {
              final name = friendDoc.data()?['name'] ?? '';
              names[friendUserId] = name;
              debugPrint('✅ 프렌즈 이름: $name');
            }
          } catch (e) {
            debugPrint('❌ 프렌즈 정보 조회 실패: $e');
          }
        }

        if (mounted) {
          setState(() {
            reservations = allReservations;
            friendNames = names;
            isLoading = false;
          });

          debugPrint('✅ 전체 예약 로드 완료: ${reservations.length}개');

          // 여러 예약이 있을 때만 타이머 시작
          if (reservations.length > 1) {
            _startTimer();
          }
          _animationController.forward();
        }
      } else {
        debugPrint('⚠️ 진행중/대기중 예약이 없습니다');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ 전체 예약 정보 로드 오류: $e');
      debugPrint('💡 Collection Group Query를 사용하려면 Firebase Console에서 인덱스를 생성해야 합니다');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _animationController.reverse().then((_) {
          setState(() {
            currentIndex = (currentIndex + 1) % reservations.length;
          });
          _animationController.forward();
        });
      }
    });
  }

  void _startCounterAnimation() {
    // 카운터 애니메이션 초기화
    _displayedCount = 0;

    // 애니메이션 지속 시간과 단계 계산
    const int animationDuration = 1000; // 1초
    const int steps = 30; // 30단계
    final int stepDuration = animationDuration ~/ steps;
    final int increment = (completedCount / steps).ceil();

    _countTimer?.cancel();
    _countTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_displayedCount + increment >= completedCount) {
          _displayedCount = completedCount;
          timer.cancel();
        } else {
          _displayedCount += increment;
        }
      });
    });
  }

  String _getLocationText(Map<String, dynamic> reservation) {
    final location = reservation['location'] as Map<String, dynamic>?;
    if (location == null) return '위치 정보 없음';

    final city = location['city'] ?? '';
    final nationality = location['nationality'] ?? '';

    // LocationMapper를 사용하여 이름 가져오기 (현재 선택된 언어 사용)
    String cityName = LocationMapper.getCityName(nationality, city, language: _currentLanguage);
    String countryName = LocationMapper.getCountryName(nationality, language: _currentLanguage);

    final friendUserId = reservation['friendUserId'];
    final friendName = friendNames[friendUserId] ?? '';

    String locationText = '$countryName, $cityName';

    if (friendName.isNotEmpty) {
      // 이름 마스킹 처리
      String maskedName;
      if (friendName.length == 1) {
        maskedName = friendName;
      } else if (friendName.length == 2) {
        maskedName = '${friendName[0]}*';
      } else {
        final first = friendName[0];
        final last = friendName[friendName.length - 1];
        final middleCount = friendName.length - 2;
        final stars = '*' * middleCount;
        maskedName = '$first$stars$last';
      }
      locationText += '  $maskedName';
    }

    return locationText;
  }

  String _getDateText(Map<String, dynamic> reservation) {
    if (reservation['useDate'] != null) {
      String useDate = reservation['useDate'];
      return _formatDate(useDate);
    }
    return '';
  }

  String _formatDate(String dateStr) {
    try {
      // "2025년 6월 2일" 형식 파싱
      final regex = RegExp(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일');
      final match = regex.firstMatch(dateStr);

      if (match != null) {
        final year = match.group(1)!;
        final month = match.group(2)!.padLeft(2, '0');
        final day = match.group(3)!.padLeft(2, '0');
        return '$year.$month.$day';
      }

      return dateStr; // 파싱 실패시 원본 반환
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusDisplay(String? status) {
    switch (status) {
      case 'pending':
        return MainTranslations.getTranslation('status_pending', _currentLanguage);
      case 'in_progress':
        return MainTranslations.getTranslation('status_in_progress', _currentLanguage);
      default:
        return MainTranslations.getTranslation('status_completed', _currentLanguage);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.pink;
    }
  }

  String _getCountUnitText() {
    return MainTranslations.getTranslation('count_unit', _currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading
          ? const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      )
          : reservations.isEmpty
          ? Row(
        children: [
          Text(
            MainTranslations.getTranslation('no_reservations_in_progress', _currentLanguage),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 진행중인 예약 정보
                Row(
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocationText(reservations[currentIndex]),
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 13,
                                  fontFamily: 'Spoqa Han Sans Neo',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_getDateText(reservations[currentIndex]).isNotEmpty)
                                Text(
                                  _getDateText(reservations[currentIndex]),
                                  style: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 12,
                                    fontFamily: 'Spoqa Han Sans Neo',
                                    fontWeight: FontWeight.w500,
                                    height: 1.50,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reservations[currentIndex]['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusDisplay(reservations[currentIndex]['status']),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(reservations[currentIndex]['status']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                // 완료된 예약 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      MainTranslations.getTranslation('total_completed_reservations', _currentLanguage),
                      style: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 12,
                        fontFamily: 'Spoqa Han Sans Neo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_displayedCount ${_getCountUnitText()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}