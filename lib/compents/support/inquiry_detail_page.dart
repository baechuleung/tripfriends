import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inquiry_service.dart';
import '../../services/translation_service.dart';  // TranslationService import 추가

class InquiryDetailPage extends StatefulWidget {
  final String inquiryId;

  const InquiryDetailPage({
    super.key,
    required this.inquiryId,
  });

  @override
  State<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends State<InquiryDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic> _inquiryData = {};
  Map<String, dynamic>? _replyData;
  final TranslationService _translationService = TranslationService();  // TranslationService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _initTranslationService();
    _loadInquiryDetail();
  }

  // TranslationService 초기화 함수
  Future<void> _initTranslationService() async {
    await _translationService.init();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadInquiryDetail() async {
    try {
      // InquiryService를 통해 문의 상세 정보 가져오기
      final inquiryDetail = await InquiryService.getInquiryDetail(widget.inquiryId);

      if (inquiryDetail != null) {
        setState(() {
          _inquiryData = inquiryDetail;
          _replyData = inquiryDetail['reply'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        // 데이터가 없는 경우 에러 처리
        throw Exception(_translationService.get('inquiry_not_found', '문의 정보를 찾을 수 없습니다.'));
      }
    } catch (e) {
      print('${_translationService.get('inquiry_detail_error', '문의 상세 조회 오류')}: $e');

      // 오류 발생 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_translationService.get('inquiry_load_fail', '문의 정보를 불러오는 중 오류가 발생했습니다.'))),
        );

        // 오류 발생 시 빈 페이지가 아닌 기본 정보라도 표시
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷팅
    String formattedDate = '';
    if (!_isLoading && _inquiryData['date'] != null) {
      final Timestamp timestamp = _inquiryData['date'] as Timestamp;
      final DateTime dateTime = timestamp.toDate();
      formattedDate =
      '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime
          .day.toString().padLeft(2, '0')}';
    }

    // 답변 날짜 포맷팅
    String replyDate = '';
    if (!_isLoading && _replyData != null && _replyData!['date'] != null) {
      final Timestamp timestamp = _replyData!['date'] as Timestamp;
      final DateTime dateTime = timestamp.toDate();
      replyDate =
      '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime
          .day.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _translationService.get('customer_service', '고객센터'),
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 문의 제목 및 날짜
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _inquiryData['title'] ?? _translationService.get('no_title', '제목 없음'),
                          style: const TextStyle(
                            color: Color(0xFF353535),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _inquiryData['status'] == '답변 완료'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTranslatedStatus(_inquiryData['status']),
                          style: TextStyle(
                            color: _inquiryData['status'] == '답변 완료'
                                ? Colors.blue
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Divider(height: 1, color: Color(0xFFE4E4E4)),
            ),

            // 문의 내용
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Text(
                _inquiryData['content'] ?? _translationService.get('no_content', '내용 없음'),
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Divider(height: 1, color: Color(0xFFE4E4E4)),
            ),

            // 답변 섹션
            if (_replyData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.subdirectory_arrow_right, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _translationService.get('reply_to_inquiry', '[문의하신 내용에 답변드립니다.]'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          replyDate,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    color: const Color(0xFFF5F5F5),
                    child: Text(
                      _replyData!['content'] ?? _translationService.get('no_reply_content', '답변 내용 없음'),
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 상태 번역 메소드
  String _getTranslatedStatus(String? status) {
    if (status == null) {
      return _translationService.get('no_status', '상태 없음');
    }

    if (status == '답변 완료') {
      return _translationService.get('answer_completed', '답변 완료');
    } else if (status == '답변 대기중') {
      return _translationService.get('pending_answer', '답변 대기중');
    } else {
      return _translationService.get(status.toLowerCase().replaceAll(' ', '_'), status);
    }
  }
}