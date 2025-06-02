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
      backgroundColor: Colors.white, // 명시적으로 배경색을 흰색으로 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // 모서리를 더 둥글게
      ),
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20), // 아이콘 크기 줄임
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _titleText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // 타이틀 글자 크기 줄임
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16), // 컨텐츠 패딩 조정
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 라디오 버튼 목록
            for (String type in _reportTypes)
              RadioListTile<String>(
                title: Text(
                  type,
                  style: const TextStyle(fontSize: 14), // 목록 항목 글자 크기 줄임
                ),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                activeColor: Colors.blue,
                contentPadding: EdgeInsets.zero,
                dense: true, // 목록 항목 간격 더 조밀하게
              ),

            // '기타' 선택 시 표시할 텍스트 필드
            if (_selectedType == _reportTypes.last) // '기타' 항목은 마지막에 있음
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _customReasonController,
                  style: const TextStyle(fontSize: 14), // 입력 필드 글자 크기 줄임
                  decoration: InputDecoration(
                    hintText: _inputHintText,
                    hintStyle: const TextStyle(fontSize: 13), // 힌트 텍스트 크기 줄임
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            _cancelButtonText,
            style: const TextStyle(fontSize: 14), // 버튼 글자 크기 줄임
          ),
        ),
        ElevatedButton(
          onPressed: _selectedType == null
              ? null  // 선택이 없으면 비활성화
              : () {
            final customReason = _selectedType == _reportTypes.last ? _customReasonController.text : null;
            widget.onReport(_selectedType!, customReason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[100],
            foregroundColor: Colors.red[900],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 패딩 조정
          ),
          child: Text(
            _reportButtonText,
            style: const TextStyle(fontSize: 14), // 버튼 글자 크기 줄임
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
  String _descriptionText = '차단 시 대화를 더 이상 주고 받을 수 없으며, 추후 동일 사용자와의 매칭되지 않습니다.';
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
            '차단 시 대화를 더 이상 주고 받을 수 없으며, 추후 동일 사용자와의 매칭되지 않습니다.');
        _blockButtonText = _translationService.get('block_button', '차단하기');
        _cancelButtonText = _translationService.get('cancel_button', '취소');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // 명시적으로 배경색을 흰색으로 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // 모서리를 더 둥글게
      ),
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20), // 아이콘 크기 줄임
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _titleText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // 타이틀 글자 크기 줄임
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16), // 컨텐츠 패딩 조정
      content: Text(
        _descriptionText,
        style: const TextStyle(fontSize: 14), // 내용 글자 크기 줄임
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            _cancelButtonText,
            style: const TextStyle(fontSize: 14), // 버튼 글자 크기 줄임
          ),
        ),
        ElevatedButton(
          onPressed: widget.onBlock,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[100],
            foregroundColor: Colors.red[900],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 버튼 패딩 조정
          ),
          child: Text(
            _blockButtonText,
            style: const TextStyle(fontSize: 14), // 버튼 글자 크기 줄임
          ),
        ),
      ],
    );
  }
}