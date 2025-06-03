// lib/chat/widgets/friend_chat_input.dart - 이미지 첨부 기능 제거
import 'package:flutter/material.dart';
import '../../services/translation_service.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onTap;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onTap,
  }) : super(key: key);

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TranslationService _translationService = TranslationService();
  final FocusNode _focusNode = FocusNode();
  bool _keepFocus = false;

  // 상태 변수
  String _hintText = '고객에게 메시지를 입력하세요...';

  @override
  void initState() {
    super.initState();
    _loadTranslations();

    // 포커스 노드 리스너 추가
    _focusNode.addListener(() {
      if (_keepFocus && !_focusNode.hasFocus) {
        Future.microtask(() => _focusNode.requestFocus());
      }
    });
  }

  // 메시지 전송 함수
  void _sendMessage() {
    if (widget.controller.text.trim().isEmpty) return;

    // 포커스 유지 플래그 설정
    _keepFocus = true;

    // 포커스 요청
    _focusNode.requestFocus();

    widget.onTap();
    widget.onSend();

    // 메시지 전송 후 포커스 유지를 위해 마이크로태스크 스케줄링
    Future.microtask(() {
      if (mounted) {
        _focusNode.requestFocus();

        // 약간의 지연 후 다시 포커스 요청 (안전장치)
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _keepFocus = false; // 이후 자동 유지 중지
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  Future<void> _loadTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {
        _hintText = _translationService.get('chat_input_hint_to_customer', '고객에게 메시지를 입력하세요...');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: SafeArea(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 메시지 입력 필드
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: _hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      _sendMessage();
                    },
                    onTap: () {
                      // 탭 시 읽음 상태 갱신만 하고 키보드는 그대로 유지
                      widget.onTap();
                    },
                  ),
                ),
              ),

              // 전송 버튼
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF237AFF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Transform.translate(
                      offset: const Offset(2, -2), // 오른쪽으로 2, 위로 2 이동
                      child: Transform.rotate(
                        angle: -0.585398, // -45도 (라디안)
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    onPressed: _sendMessage,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}