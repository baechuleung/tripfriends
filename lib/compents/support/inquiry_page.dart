import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inquiry_detail_page.dart';
import 'inquiry_form_page.dart';
import 'inquiry_service.dart';
import '../../services/translation_service.dart';  // TranslationService import 추가

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _inquiries = [];
  final TranslationService _translationService = TranslationService();  // TranslationService 인스턴스 추가

  @override
  void initState() {
    super.initState();
    _initTranslationService();
    _loadInquiries();
  }

  // TranslationService 초기화 함수
  Future<void> _initTranslationService() async {
    await _translationService.init();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadInquiries() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final inquiriesData = await InquiryService.getInquiries();

      if (mounted) {
        setState(() {
          _inquiries = inquiriesData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('${_translationService.get('inquiry_load_error', '문의 목록 로드 오류')}: $e');
      if (mounted) {
        setState(() {
          _inquiries = [];
          _isLoading = false;
        });

        print(_translationService.get('inquiry_load_fail', '문의 내역을 불러오는 중 오류가 발생했습니다'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_inquiries.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _translationService.get('no_inquiry_history', '아직 문의 내역이 없습니다.'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          _buildInquiryButton(),
          const SizedBox(height: 32),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInquiries,
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: _inquiries.length,
              separatorBuilder: (context, index) => const Divider(height: 0.5, color: Color(0xFFE4E4E4)),
              itemBuilder: (context, index) {
                final inquiry = _inquiries[index];
                final title = inquiry['title'] as String? ?? _translationService.get('default_inquiry_title', '환불 처리는 어떻게 해야할까요?');
                final date = inquiry['date'] as Timestamp?;
                final status = inquiry['status'] as String? ?? _translationService.get('pending_answer', '답변 대기중');

                String formattedDate = '';
                if (date != null) {
                  final postDate = date.toDate();
                  formattedDate = '${postDate.year}.${postDate.month.toString().padLeft(2, '0')}.${postDate.day.toString().padLeft(2, '0')}';
                } else {
                  formattedDate = '2025.02.26';
                }

                // 상태 번역 - 상태별로 직접 번역 키 매핑
                String translatedStatus;
                if (status == '답변 완료') {
                  translatedStatus = _translationService.get('answer_completed', '답변 완료');
                } else if (status == '답변 대기중') {
                  translatedStatus = _translationService.get('pending_answer', '답변 대기중');
                } else {
                  // 그 외 상태는 기존 방식으로 변환
                  translatedStatus = _translationService.get(status.toLowerCase().replaceAll(' ', '_'), status);
                }

                Color statusColor;
                switch (status) {
                  case '답변 완료':
                    statusColor = Colors.blue;
                    break;
                  case '답변 대기중':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF353535),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          translatedStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InquiryDetailPage(
                          inquiryId: inquiry['id'],
                        ),
                      ),
                    ).then((_) {
                      // 상세 페이지에서 돌아온 후 목록 새로고침
                      _loadInquiries();
                    });
                  },
                );
              },
            ),
          ),
          _buildInquiryButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInquiryButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InquiryFormPage()),
          ).then((_) {
            // 문의 작성 페이지에서 돌아온 후 목록 새로고침
            _loadInquiries();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF237AFF),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          _translationService.get('one_to_one_inquiry_button', '1:1 문의하기'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}