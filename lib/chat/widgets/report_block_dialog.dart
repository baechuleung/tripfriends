// lib/chat/widgets/report_block_dialog.dart
import 'package:flutter/material.dart';
import '../../services/translation_service.dart';

// 신고하기 다이얼로그
class ReportDialog extends StatefulWidget {
  final Function(String, String?) onReport;
  final VoidCallback onCancel;

  const ReportDialog({
    Key? key,
    required this.onReport,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TranslationService _translationService = TranslationService();

  // 신고 타입 옵션들 - 초기 기본값으로 설정
  List<String> _reportTypes = [
    '욕설 / 비방',
    '무례한 태도 / 반복된 불쾌한 요구',
    '금전 요구 또는 불법행위 비용요청',
    '외부 서비스 권유/앱 외 거래 시도',
    '기타'
  ];

  // 신고 타입 키 - 번역 키로 사용
  final List<String> _reportTypeKeys = [
    'report_type_abusive',
    'report_type_rude',
    'report_type_money',
    'report_type_external_service',
    'report_type_other'
  ];

  // 선택된 신고 타입
  String? _selectedType;

  // 기타 이유 텍스트 컨트롤러
  final TextEditingController _customReasonController = TextEditingController();

  // 번역된 텍스트
  String _titleText = '해당 사용자를 신고하시겠어요?';
  String _reportButtonText = '신고하기';
  String _cancelButtonText = '취소';
  String _inputHintText = '신고 이유를 입력하세요';

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // 번역 로드
  Future<void> _loadTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {
        // 기본 텍스트 번역
        _titleText = _translationService.get('chat_report_user_title', '해당 사용자를 신고하시겠어요?');
        _reportButtonText = _translationService.get('report_button', '신고하기');
        _cancelButtonText = _translationService.get('cancel_button', '취소');
        _inputHintText = _translationService.get('report_reason_hint', '신고 이유를 입력하세요');

        // 신고 유형 번역
        final translatedTypes = <String>[];
        for (int i = 0; i < _reportTypeKeys.length; i++) {
          final key = _reportTypeKeys[i];
          final defaultValue = _reportTypes[i];
          final translatedValue = _translationService.get(key, defaultValue);
          translatedTypes.add(translatedValue);
        }
        _reportTypes = translatedTypes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40), // 가장자리 여백 늘려서 팝업 너비 줄임
      title: Container(
        width: MediaQuery.of(context).size.width * 0.85, // 85%로 줄임
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF353535),
                fontSize: 16,
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 16), // 상단 패딩 증가
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85, // 85%로 줄임
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 라디오 버튼 목록
              for (int i = 0; i < _reportTypes.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12), // 간격 더 늘림 (10 -> 12)
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = _reportTypes[i];
                      });
                    },
                    child: Row(
                      children: [
                        // 커스텀 체크박스
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: _selectedType == _reportTypes[i]
                                  ? const Color(0xFF237AFF)
                                  : const Color(0xFFE0E0E0),
                              width: 2,
                            ),
                          ),
                          child: _selectedType == _reportTypes[i]
                              ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF237AFF),
                              ),
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // 텍스트
                        Expanded(
                          child: Text(
                            _reportTypes[i],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // '기타' 선택 시 표시할 텍스트 필드
              if (_selectedType == _reportTypes.last) // '기타' 항목은 마지막에 있음
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 8.0), // 상단 간격 더 늘림
                  child: TextField(
                    controller: _customReasonController,
                    style: const TextStyle(fontSize: 14), // 입력 필드 글자 크기 줄임
                    decoration: InputDecoration(
                      hintText: _inputHintText,
                      hintStyle: const TextStyle(fontSize: 13), // 힌트 텍스트 크기 줄임
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // 라운드 증가
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0), // 체크박스와 동일한 회색
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF237AFF), // 포커스 시 파란색
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 20), // 좌우 패딩 제거
          width: double.infinity, // 가로로 꽉 차게
          child: Row(
            children: [
              // 취소 버튼
              Expanded(
                child: GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _cancelButtonText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          height: 1.71,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 신고하기 버튼
              Expanded(
                child: GestureDetector(
                  onTap: _selectedType == null
                      ? null
                      : () {
                    final customReason = _selectedType == _reportTypes.last ? _customReasonController.text : null;
                    widget.onReport(_selectedType!, customReason);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _selectedType == null
                          ? const Color(0xFFFFE8E8).withOpacity(0.5)
                          : const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _reportButtonText,
                        style: TextStyle(
                          color: _selectedType == null
                              ? const Color(0xFFFF5050).withOpacity(0.5)
                              : const Color(0xFFFF5050),
                          fontSize: 14,
                          fontFamily: 'Spoqa Han Sans Neo',
                          fontWeight: FontWeight.w500,
                          height: 1.71,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }
}

// 차단하기 다이얼로그
class BlockDialog extends StatefulWidget {
  final Function() onBlock;
  final VoidCallback onCancel;

  const BlockDialog({
    Key? key,
    required this.onBlock,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<BlockDialog> {
  final TranslationService _translationService = TranslationService();

  // 번역된 텍스트
  String _titleText = '이 여행자를 차단하시겠어요?';
  String _descriptionText = '차단 시 대화를 더 이상 주고 받을 수 없으며,\n추후 동일 사용자와다시 매칭되지 않습니다.';
  String _blockButtonText = '차단하기';
  String _cancelButtonText = '취소';

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  // 번역 로드
  Future<void> _loadTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {
        _titleText = _translationService.get('chat_block_user_title', '이 여행자를 차단하시겠어요?');
        _descriptionText = _translationService.get('chat_block_user_description',
            '차단 시 대화를 더 이상 주고 받을 수 없으며,\n추후 동일 사용자와다시 매칭되지 않습니다.');
        _blockButtonText = _translationService.get('block_button', '차단하기');
        _cancelButtonText = _translationService.get('cancel_button', '취소');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 (아이콘 포함)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _titleText,
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 16,
                    fontFamily: 'Spoqa Han Sans Neo',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 설명
            Text(
              _descriptionText,
              style: const TextStyle(
                color: Color(0x7F14181F),
                fontSize: 14,
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 버튼들
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _cancelButtonText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w500,
                            height: 1.71,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 차단하기 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onBlock,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _blockButtonText,
                          style: const TextStyle(
                            color: Color(0xFFFF5050),
                            fontSize: 14,
                            fontFamily: 'Spoqa Han Sans Neo',
                            fontWeight: FontWeight.w500,
                            height: 1.71,
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
      ),
    );
  }
}