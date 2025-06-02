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
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 메시지 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: _hintText,
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
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
            ),

            const SizedBox(width: 8),

            // 전송 버튼 - 클릭 시 키보드가 내려가지 않도록 설정
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF00897B),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),
          ],
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