// lib/chat/widgets/friend_message_bubble.dart - 트립프렌즈 앱(프렌즈용)
import 'package:flutter/material.dart';
import '../models/friend_chat_message.dart';
import '../../services/google_translation_service.dart';
import '../../services/translation_service.dart';

// 전역 번역 상태 관리 맵 - 메시지 컨텐츠+시간 기준 (위젯 재생성 시에도 상태 유지)
final Map<String, String?> _translatedTextCache = {};
final Map<String, bool> _isTranslatingCache = {};

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final String? customerImage;

  // 프렌즈 앱 메시지 색상 (초록색 계열) - 클래스 수준 상수로 변경
  static const Color myBubbleColor = Color(0xFF00897B);

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.customerImage,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final GoogleTranslationService _translationService = GoogleTranslationService();
  final TranslationService _appTranslationService = TranslationService();

  // 버튼 텍스트
  String _translateButtonText = '번역';
  String _originalButtonText = '원문';
  bool _translationLoaded = false;

  // 현재 메시지 고유 식별자 (내용+시간으로 생성)
  String get _messageKey =>
      '${widget.message.content}_${widget.message.timestamp.millisecondsSinceEpoch}_${widget.message.senderId}';

  // 현재 메시지의 번역된 텍스트 getter/setter
  String? get _translatedText => _translatedTextCache[_messageKey];
  set _translatedText(String? value) => _translatedTextCache[_messageKey] = value;

  // 현재 메시지의 번역 진행 중 상태 getter/setter
  bool get _isTranslating => _isTranslatingCache[_messageKey] ?? false;
  set _isTranslating(bool value) => _isTranslatingCache[_messageKey] = value;

  @override
  void initState() {
    super.initState();
    _loadButtonTexts();

    // 초기화: 메시지 키에 해당하는 번역 상태가 없으면 초기화
    if (!_isTranslatingCache.containsKey(_messageKey)) {
      _isTranslatingCache[_messageKey] = false;
    }

    // 디버그용: 초기화 시 현재 메시지 키 출력
    print('메시지 버블 초기화: 메시지 키=$_messageKey');
  }

  // 버튼 텍스트 로드
  Future<void> _loadButtonTexts() async {
    await _appTranslationService.init();
    if (mounted) {
      setState(() {
        _translateButtonText = _appTranslationService.get('translate_button_text', '번역');
        _originalButtonText = _appTranslationService.get('original_button_text', '원문');
        _translationLoaded = true;
      });
    }
  }

  // 번역 요청 함수
  Future<void> _translateMessage() async {
    if (_translatedText != null) {
      // 이미 번역된 경우 번역 내용 제거
      setState(() {
        _translatedText = null;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await _translationService.translateText(widget.message.content);

      if (mounted) {
        setState(() {
          _translatedText = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('번역 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // 단순한 시간 포맷팅 (HH:mm 형식만 반환)
  String _formatSimpleTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 내가 보낸 메시지와 상대방 메시지에 대한 서로 다른 BorderRadius 설정
    final BorderRadius messageBorderRadius = widget.isMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(0),  // 오른쪽 위 모서리는 라운드 없음
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(0),  // 왼쪽 위 모서리는 라운드 없음
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // 프로필 이미지는 상단에 배치
        children: [
          if (!widget.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.customerImage != null
                  ? NetworkImage(widget.customerImage!)
                  : null,
              child: widget.customerImage == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
              backgroundColor: Colors.blue.shade100, // 고객 아바타 색상
            ),
            const SizedBox(width: 8),
          ],

          // 컨텐츠 부분을 훨씬 아래로 내리기 위해 별도의 Column으로 감싸고 SizedBox 추가
          Column(
            children: [
              // 컨텐츠를 프로필 이미지보다 훨씬 아래로 내리기 위한 공간
              if (!widget.isMe) const SizedBox(height: 20),

              Column(
                crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 내가 보낸 메시지일 경우 시간과 체크 마크를 왼쪽에 표시 (체크 마크가 위쪽)
                      if (widget.isMe) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 체크 마크를 시간 위에 배치
                            Icon(
                              widget.message.isRead ? Icons.done_all : Icons.done,
                              size: 12,
                              color: widget.message.isRead ? Colors.teal : Colors.grey[600],
                            ),
                            const SizedBox(height: 2),
                            // 시간
                            Text(
                              _formatSimpleTime(widget.message.timestamp),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                      ],

                      // 메시지 버블
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isMe ? MessageBubble.myBubbleColor : Colors.grey[200],
                          borderRadius: messageBorderRadius, // 커스텀 BorderRadius 적용
                        ),
                        child: _isTranslating
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.message.content,
                              style: TextStyle(
                                color: widget.isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Center(
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.message.content,
                              style: TextStyle(
                                color: widget.isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            if (_translatedText != null) ...[
                              const SizedBox(height: 8),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: widget.isMe
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _translatedText!,
                                style: TextStyle(
                                  color: widget.isMe
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black87.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 상대방이 보낸 메시지일 경우 시간을 메시지 오른쪽에 표시
                      if (!widget.isMe) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            _formatSimpleTime(widget.message.timestamp),
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // 번역 버튼을 콘텐츠 아래로 이동 (상대방 메시지만, 번역 중이거나 이미 번역된 경우 표시 안함)
                  if (!widget.isMe && !_isTranslating && _translatedText == null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: GestureDetector(
                        onTap: _translateMessage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _translateButtonText,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}