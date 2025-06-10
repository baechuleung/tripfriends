import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/reservation_model.dart';
import '../../controllers/reservation_controller.dart';
import '../../../translations/reservation_translations.dart';
import '../../services/map_service.dart';
import '../common/purpose_translations.dart';
import '../common/date_translations.dart';
import '../common/reservation_chat_button_widget.dart';
import '../../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class PastReservationCardWidget extends StatefulWidget {
  final Reservation reservation;
  final String? currentUserId;

  const PastReservationCardWidget({
    Key? key,
    required this.reservation,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<PastReservationCardWidget> createState() => _PastReservationCardWidgetState();
}

class _PastReservationCardWidgetState extends State<PastReservationCardWidget> {
  final MapService _mapService = MapService();
  bool _isExpanded = false;
  late PurposeTranslations _purposeTranslations;
  late DateTranslations _dateTranslations;
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;
    _purposeTranslations = PurposeTranslations(_currentLanguage);
    _dateTranslations = DateTranslations(_currentLanguage);

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
          _purposeTranslations = PurposeTranslations(_currentLanguage);
          _dateTranslations = DateTranslations(_currentLanguage);
        });
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  // 지도 URL을 여는 메서드
  Future<void> _openMapUrl(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $mapUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ReservationController();
    final reservation = widget.reservation;

    // 디버그 로그 추가
    print('예약 정보 확인: customerId=${reservation.customerId}, customerName=${reservation.customerName}');

    // 날짜에서 년, 월, 일 단어만 번역 키를 통해 처리
    final String dateStr = _dateTranslations.translateDateFormat(reservation.useDate);

    // 결제 금액 포맷
    final formattedPrice = controller.formatPrice(
        reservation.basePrice,
        reservation.currencySymbol
    );

    // 사용 목적 문자열 생성 (번역 키를 통해 변환)
    final purposeText = _purposeTranslations.translatePurposeList(reservation.purpose);

    // 주소 정보 (meetingAddress가 있으면 사용, 없으면 address 사용)
    final String addressText = reservation.meetingAddress.isNotEmpty
        ? reservation.meetingAddress
        : reservation.address;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더 (흰색 배경)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 예약 번호 (왼쪽)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: Center(
                    child: Text(
                      '${reservation.reservationNumber}',
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),
                // 서비스 완료 상태 (오른쪽)
                Text(
                  ReservationTranslations.getTranslation('service_completed_short', _currentLanguage),
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 최종 요금 섹션 (클릭 가능)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ReservationTranslations.getTranslation('final_price', _currentLanguage),
                        style: const TextStyle(
                          color: Color(0xFF353535),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            controller.formatPrice(reservation.totalPriceInfo, reservation.currencySymbol),
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 이용 시간 표시
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF999999),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: Text(
                              reservation.usedTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 화살표 아이콘
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // 세부 정보 내용 (접었다 펴는 부분)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 구분선
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Color(0xFFE5E5E5)),
                  ),

                  // 예약상세 정보 텍스트
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      ReservationTranslations.getTranslation('reservation_details', _currentLanguage),
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 고객 이름
                        Row(
                          children: [
                            const Icon(Icons.assignment_ind_outlined, size: 16, color: Color(0xFFCFCFCF)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reservation.customerName,
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 2. 인원수
                        Row(
                          children: [
                            const Icon(Icons.group_outlined, size: 16, color: Color(0xFFCFCFCF)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${reservation.personCount}${ReservationTranslations.getTranslation("people_count", _currentLanguage)}',
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 3. 날짜
                        Row(
                          children: [
                            const Icon(Icons.event_available_outlined, size: 16, color: Color(0xFFCFCFCF)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 4. 시작 시간
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Color(0xFFCFCFCF)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reservation.startTime.isNotEmpty
                                    ? reservation.startTime
                                    : reservation.useTime,
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 5. 일정 목적
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(Icons.interests_outlined, size: 16, color: const Color(0xFFCFCFCF)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                purposeText,
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 6. 주소(지도)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFCFCFCF)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _openMapUrl(addressText),
                                      child: Text(
                                        addressText,
                                        style: const TextStyle(
                                          color: Color(0xFF353535),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _openMapUrl(addressText),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.zero,
                                      height: 20,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                          Icons.map,
                                          color: Color(0xFF999999),
                                          size: 20
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 버튼 섹션 - 채팅하기 버튼만 표시
          ReservationChatButtonWidget(
            customerId: reservation.customerId,
            customerName: reservation.customerName,
            currentUserId: widget.currentUserId,
            currentLanguage: _currentLanguage,
          ),
        ],
      ),
    );
  }
}