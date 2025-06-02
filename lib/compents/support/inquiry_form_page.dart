import 'package:flutter/material.dart';
import 'inquiry_service.dart';
import '../../services/translation_service.dart';  // TranslationService import 추가

class InquiryFormPage extends StatefulWidget {
  const InquiryFormPage({super.key});

  @override
  State<InquiryFormPage> createState() => _InquiryFormPageState();
}

class _InquiryFormPageState extends State<InquiryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TranslationService _translationService = TranslationService();  // TranslationService 인스턴스 추가

  String _selectedCategory = '일반문의';
  bool _isSubmitting = false;

  List<String> _categories = [];
  Map<String, String> _categoryTranslationMap = {};

  @override
  void initState() {
    super.initState();
    _initTranslationService();
  }

  // TranslationService 초기화 함수 및 카테고리 설정
  Future<void> _initTranslationService() async {
    await _translationService.init();

    // 카테고리 번역 맵 초기화
    _categoryTranslationMap = {
      'general_inquiry': '일반문의',
      'user_inquiry': '사용자 관련문의',
      'reservation_inquiry': '예약 및 일정 조정 문의',
      'technical_issue': '기술 문제 신고',
    };

    // 번역된 카테고리 리스트 생성
    _categories = [
      _translationService.get('general_inquiry', '일반문의'),
      _translationService.get('user_inquiry', '사용자 관련문의'),
      _translationService.get('reservation_inquiry', '예약 및 일정 조정 문의'),
      _translationService.get('technical_issue', '기술 문제 신고'),
    ];

    // 초기 선택 카테고리도 번역
    _selectedCategory = _translationService.get('general_inquiry', '일반문의');

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 키보드 숨기는 함수 추가
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // 선택된 카테고리의 원래 값(서버에 저장될 값) 가져오기
  String _getOriginalCategoryValue(String translatedCategory) {
    // 번역된 값으로 원래 키 찾기
    String? originalKey = _categoryTranslationMap.entries
        .firstWhere(
          (entry) => _translationService.get(entry.key, entry.value) == translatedCategory,
      orElse: () => const MapEntry('general_inquiry', '일반문의'),
    ).key;

    // 원래 카테고리 값 반환
    return _categoryTranslationMap[originalKey] ?? '일반문의';
  }

  Future<void> _submitInquiry() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // 제목과 내용이 비어있는지 확인
    if (_titleController.text.trim().isEmpty) {
      // ScaffoldMessenger 대신 print 사용
      print(_translationService.get('enter_inquiry_title', '문의 제목을 입력해주세요'));
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      // ScaffoldMessenger 대신 print 사용
      print(_translationService.get('enter_inquiry_content', '문의 내용을 입력해주세요'));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 서버에 저장할 원래 카테고리 값 가져오기
      String originalCategory = _getOriginalCategoryValue(_selectedCategory);

      // InquiryService를 통해 문의 등록
      final success = await InquiryService.createInquiry(
        category: originalCategory,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (success) {
        if (mounted) {
          // ScaffoldMessenger 대신 print 사용
          print(_translationService.get('inquiry_submitted_success', '문의가 성공적으로 제출되었습니다'));
          Navigator.pop(context);
        }
      } else {
        throw Exception(_translationService.get('inquiry_submit_fail', '문의 등록에 실패했습니다'));
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger 대신 print 사용
        print('${_translationService.get('inquiry_submit_error', '문의 제출 중 오류가 발생했습니다')}: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 화면의 아무 곳이나 탭하면 키보드가 내려가도록 설정
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _translationService.get('customer_service', '고객센터'),
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // 스크롤 제스처가 GestureDetector와 충돌하지 않도록 behavior 설정
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 선택 버튼 그룹
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF237AFF).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF237AFF) : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF237AFF) : const Color(0xFF666666),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // 문의 제목 입력 필드 (추가됨)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: _translationService.get('title', '제목'),
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                    maxLines: 1,
                  ),
                ),

                const SizedBox(height: 16),

                // 문의 내용 입력 필드
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextFormField(
                    controller: _contentController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: _translationService.get('enter_content', '내용 입력'),
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 버튼 영역
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            _translationService.get('cancel', '취소'),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitInquiry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF237AFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: const Color(0xFF237AFF).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            _translationService.get('submit_inquiry', '문의 접수'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}