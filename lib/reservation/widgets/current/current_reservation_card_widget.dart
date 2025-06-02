import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // URL 실행을 위한 패키지 추가
import '../../models/reservation_model.dart';
import '../../controllers/reservation_controller.dart';
import '../../../services/translation_service.dart';
import '../common/reservation_chat_button_widget.dart';
import '../common/time_price_service.dart'; // 통합된 서비스로 변경
import '../../services/map_service.dart';
import '../common/purpose_translations.dart';
import '../common/date_translations.dart'; // 날짜 번역 클래스 임포트

class CurrentReservationCardWidget extends StatefulWidget {
  final Reservation reservation;
  final TranslationService translationService;
  final String? currentUserId;

  const CurrentReservationCardWidget({
    Key? key,
    required this.reservation,
    required this.translationService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CurrentReservationCardWidget> createState() => _CurrentReservationCardWidgetState();
}

class _CurrentReservationCardWidgetState extends State<CurrentReservationCardWidget> {
  final Map<String, String> _translatedTexts = {};
  final MapService _mapService = MapService();
  bool _isExpanded = false; // 접었다 펴는 상태 관리
  late PurposeTranslations _purposeTranslations;
  late DateTranslations _dateTranslations; // 날짜 번역 객체
  late TimePriceService _timePriceService; // 변경된 코드: 통합된 서비스 사용

  @override
  void initState() {
    super.initState();
    _purposeTranslations = PurposeTranslations(widget.translationService);
    _dateTranslations = DateTranslations(widget.translationService); // 날짜 번역 객체 초기화
    _timePriceService = TimePriceService(widget.translationService); // 변경된 코드: 통합된 서비스 초기화
  }

  // 지도 URL을 여는 메서드
  Future<void> _openMapUrl(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } else {
      // URL을 열 수 없는 경우 - 오류 처리
      print('Could not launch $mapUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ReservationController();
    final t = widget.translationService;
    final reservation = widget.reservation;

    // 디버그 로그 추가
    print('예약 정보 확인: customerId=${reservation.customerId}, customerName=${reservation.customerName}');

    // 날짜에서 년, 월, 일 단어만 번역 키를 통해 처리
    final String dateStr = _dateTranslations.translateDateFormat(reservation.useDate);

    // 요일 정보가 있으면 사용하고, 없으면 빈 문자열
    final String dayOfWeek = '';

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

    // 도시 코드 가져오기
    final String cityCode = reservation.getField('location')?['city'] ?? 'SEL';

    // pending 상태일 경우 시간 차이 계산 - 변경된 코드: 통합된 서비스 사용
    String timeRemainingText = '';
    if (reservation.status == 'pending') {
      timeRemainingText = _timePriceService.calculateTimeRemaining(
          reservation.useDate,
          reservation.startTime,
          cityCode
      );
    }

    // 실시간 요금 및 이용 시간 계산 - 변경된 코드: 통합된 서비스 사용
    final realTimePriceData = _timePriceService.calculateRealTimePrice(
      status: reservation.status,
      pricePerHour: reservation.pricePerHour,
      useDate: reservation.useDate,
      startTime: reservation.startTime,
      cityCode: cityCode,
    );

    // 계산된 실시간 요금
    final realTimePrice = realTimePriceData['realTimePrice'];

    // 계산된 이용 시간
    final usedTime = realTimePriceData['usedTime'];

    // 실시간 요금 포맷팅 - 변경된 코드: 통합된 서비스 사용
    final formattedRealTimePrice = _timePriceService.formatPrice(
        realTimePrice,
        reservation.currencySymbol
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: reservation.status == 'pending' ? Colors.white : const Color(0xFFE8F2FF),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 번째 줄: 예약 상태(왼쪽)와 예약번호(오른쪽)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 예약 상태 (왼쪽 정렬)
                    Text(
                      // 상태에 따라 다른 메시지 표시
                      reservation.status == 'pending'
                          ? t.get('reservation_pending', '예약완료')
                          : t.get('reservation_in_progress', '진행중'),
                      style: const TextStyle(
                        color: Color(0xFF3A53AF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // 예약 번호 (오른쪽 정렬)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE8F2FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Text(
                        '${t.get("reservation_number", "예약번호")} ${reservation.reservationNumber}',
                        style: const TextStyle(
                          color: Color(0xFF3182F6),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                // 두 번째 줄: 시간 차이 표시 (pending 상태일 때만)
                if (reservation.status == 'pending' && timeRemainingText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      timeRemainingText,
                      style: const TextStyle(
                        color: Color(0xFF3A53AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 구분선
          const Divider(height: 1, color: Color(0xFFE5E5E5)),

          // 실시간 요금 섹션 - 업데이트된 부분
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('real_time_price', '실시간 요금'),
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Row의 요소들을 양쪽 끝으로 배치
                      children: [
                        // 왼쪽 영역: 실시간 요금과 이용 시간
                        Row(
                          children: [
                            Text(
                              // 실시간 요금 서비스를 통해 계산된 값 사용
                              formattedRealTimePrice,
                              style: const TextStyle(
                                color: Color(0xFF353535),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 이용 시간 표시 - 계산된 값 사용
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF0059B7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Text(
                                usedTime,
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

                        // 오른쪽 영역: 새로고침 아이콘 (배경 없이, 크기 증가, 왼쪽 여백 추가)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0), // 왼쪽 여백 추가
                          child: GestureDetector(
                            onTap: () {
                              // 상태 업데이트를 통해 UI 새로고침
                              setState(() {
                                // 상태가 변경되면 build 메서드가 다시 호출되어 실시간 요금이 재계산됨
                              });
                            },
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF3182F6),
                              size: 24, // 아이콘 크기 증가
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 접을 수 있는 세부 정보 섹션
          // 헤더 부분 (항상 표시)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    t.get('reservation_details', '예약 상세 정보'),
                    style: const TextStyle(
                      color: Color(0xFF353535),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
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
              child: Padding(
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
                            maxLines: 3, // 최대 3줄까지 표시
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
                            '${reservation.personCount}${t.get("people_count", "명")}',
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3, // 최대 3줄까지 표시
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
                            dateStr, // 년, 월, 일 형식의 날짜
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3, // 최대 3줄까지 표시
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
                            maxLines: 3, // 최대 3줄까지 표시
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
                            purposeText, // 번역된 목적 텍스트
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3, // 최대 3줄까지 표시
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 6. 주소(지도) - 밑줄 추가 및 지도 아이콘 추가 (같은 줄에 배치)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFCFCFCF)),
                        ),
                        const SizedBox(width: 8),
                        // 주소 텍스트와 지도 아이콘을 하나의 Row로 묶음
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
                            children: [
                              // 주소 텍스트 (클릭 가능)
                              Expanded(
                                child: InkWell(
                                  onTap: () => _openMapUrl(addressText),
                                  child: Text(
                                    addressText,
                                    style: const TextStyle(
                                      color: Color(0xFF353535),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline, // 밑줄 추가
                                    ),
                                    maxLines: 3, // 최대 3줄까지 표시
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              // 지도 아이콘 (같은 줄에 배치) - 패딩 제거 및 정렬 조정
                              GestureDetector(
                                onTap: () => _openMapUrl(addressText),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  height: 20, // 높이 명시적 설정
                                  alignment: Alignment.center, // 중앙 정렬
                                  child: const Icon(
                                      Icons.map,
                                      color: Color(0xFF3182F6),
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
            ),
          ),

          // 구분선
          const Divider(height: 1, color: Color(0xFFE5E5E5)),

          // 버튼 섹션 - 채팅하기 버튼만 표시
          ReservationChatButtonWidget(
            customerId: reservation.customerId,
            customerName: reservation.customerName,
            currentUserId: widget.currentUserId,
            translationService: widget.translationService,
          ),
        ],
      ),
    );
  }
}