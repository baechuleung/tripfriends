// lib/chat/screens/friend_chat_screen.dart - 트립프렌즈 앱(프렌즈용)
import 'package:flutter/material.dart';
import '../services/friend_chat_service.dart';
import '../services/friend_message_reader.dart';
import '../models/friend_chat_message.dart';
import '../widgets/friend_chat_date_header.dart';
import '../widgets/friend_message_bubble.dart';
import '../widgets/friend_chat_input.dart';
import '../widgets/friend_chat_popup_menu.dart'; // 새로 추가된 팝업 메뉴 위젯
import '../services/friend_message_formatter.dart';
import '../../services/translation_service.dart';
import '../../services/fcm_service/handlers/chat_handler.dart'; // ChatHandler 추가

class ChatScreen extends StatefulWidget {
  final String friendsId;
  final String customerId;
  final String customerName;
  final String? customerImage;

  const ChatScreen({
    Key? key,
    required this.friendsId,
    required this.customerId,
    required this.customerName,
    this.customerImage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final MessageReaderService _messageReaderService = MessageReaderService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TranslationService _translationService = TranslationService();

  DateTime _lastRefreshTime = DateTime.now();
  String? _customerProfileUrl;
  String? _customerName;
  bool _initialLoadComplete = false;
  List<ChatMessage> _messages = []; // 메시지 목록 캐싱
  late String _chatId; // 현재 채팅방 ID

  // 번역 텍스트 변수들
  String _customerLabelText = '고객';
  String _emptyStateTitle = '고객과의 대화가 여기에 표시됩니다.\n메시지를 보내 대화를 시작해보세요!';
  String _errorStateText = '에러가 발생했습니다';
  String _sendFailText = '메시지 전송 실패';

  @override
  void initState() {
    super.initState();
    // 위젯 바인딩 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    // 채팅방 ID 계산
    _chatId = _chatService.getChatId(widget.friendsId, widget.customerId);

    print('채팅 화면 진입: 채팅방 ID $_chatId');

    // 채팅방 진입 시 현재 채팅방 정보 설정 (ChatHandler 사용)
    ChatHandler.setCurrentChatRoom(
        widget.friendsId,
        widget.customerId,
        chatId: _chatId
    );

    // 번역 로드
    _loadTranslations();

    // 채팅방 입장 시 메시지를 읽음 상태로 표시
    _messageReaderService.markMessagesAsRead(widget.friendsId, widget.customerId);

    // 디버깅용 로그 - 프렌즈앱의 사용자 ID 확인
    print('프렌즈앱 - 프렌즈ID: ${widget.friendsId}, 고객ID: ${widget.customerId}');

    // 고객 프로필 정보 가져오기
    _loadCustomerProfile();

    // 메시지 목록 초기 로드
    _loadMessages();
  }

  // 앱 상태 변경 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 포그라운드로 돌아왔을 때
    if (state == AppLifecycleState.resumed) {
      // 채팅방 상태 다시 설정
      ChatHandler.setCurrentChatRoom(
          widget.friendsId,
          widget.customerId,
          chatId: _chatId
      );
      // 읽음 상태 갱신
      _refreshReadStatus();
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 갈 때 상태 초기화
      ChatHandler.clearCurrentChatRoom();
    }
  }

  // 번역 로드
  Future<void> _loadTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {
        // 모든 번역 텍스트 로드
        _customerLabelText = _translationService.get('chat_customer_label', '고객');
        _emptyStateTitle = _translationService.get('chat_empty_state_message',
            '고객과의 대화가 여기에 표시됩니다.\n메시지를 보내 대화를 시작해보세요!');
        _errorStateText = _translationService.get('chat_error_state', '에러가 발생했습니다');
        _sendFailText = _translationService.get('chat_send_fail', '메시지 전송 실패');
      });
    }
  }

  // 메시지 목록 로드
  void _loadMessages() {
    _chatService.getMessages(widget.friendsId, widget.customerId)
        .listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
          _initialLoadComplete = true;

          // 읽지 않은 메시지 자동 읽음 표시
          final unreadMessages = messages.where((msg) =>
          msg.senderId == widget.customerId && !msg.isRead).toList();

          if (unreadMessages.isNotEmpty) {
            _refreshReadStatus();
          }
        });
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 화면 크기나 키보드 상태가 변경될 때의 작업
  }

  // 고객 프로필 정보 로드 메서드
  Future<void> _loadCustomerProfile() async {
    try {
      final customerInfo = await _chatService.getCustomerInfo(widget.customerId);
      if (mounted) {
        setState(() {
          _customerProfileUrl = customerInfo['profileImageUrl'];
          _customerName = customerInfo['name'];
          print('고객 프로필 정보 로드됨: 이름=$_customerName, URL=$_customerProfileUrl');
        });
      }
    } catch (e) {
      print('고객 프로필 로드 오류: $e');
    }
  }

  // 메시지 읽음 상태 갱신 함수 - 디바운싱 적용
  void _refreshReadStatus() {
    final now = DateTime.now();
    // 마지막 새로고침 이후 1초 이상 지났을 때만 실행 (과도한 호출 방지)
    if (now.difference(_lastRefreshTime).inMilliseconds > 1000) {
      _lastRefreshTime = now;
      // 빠른 읽음 표시 사용
      _messageReaderService.quickMarkAsRead(widget.friendsId, widget.customerId);
      print('화면 터치로 읽음 상태 업데이트: ${DateTime.now()}');
    }
  }

  // 키보드 내리기 및 포커스 해제 함수
  void _dismissKeyboard() {
    // 현재 포커스 노드에서 포커스 해제하여 키보드 닫기
    FocusScope.of(context).unfocus();
  }

  // 메시지 전송 함수
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // 디버깅 로그 추가 - ID값 확인
    print('메시지 전송 - 프렌즈ID: ${widget.friendsId}, 고객ID: ${widget.customerId}');

    try {
      // 현재 컨트롤러에서 텍스트 가져오기 (클리어 전에)
      final messageText = _messageController.text.trim();

      // 텍스트 필드 즉시 초기화
      _messageController.clear();

      // 메시지 전송
      await _chatService.sendMessage(
        widget.friendsId,
        widget.customerId,
        messageText,
      );

      // 메시지 전송 후 읽음 상태 갱신
      _refreshReadStatus();
    } catch (e) {
      if (!mounted) return;
      // 스낵바 대신 디버그 프린트로 변경
      print('$_sendFailText: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 고객 프로필 정보 - 매개변수로 전달된 값 또는 Firestore에서 가져온 값 사용
    final customerImageUrl = widget.customerImage ?? _customerProfileUrl;
    final customerName = _customerName ?? widget.customerName;

    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 시 채팅방 떠나기
        ChatHandler.clearCurrentChatRoom(); // ChatHandler 상태 초기화
        await _chatService.leaveChat();
        print('뒤로 가기 - 채팅방 비활성화');
        return true; // true를 반환하면 뒤로 가기 허용
      },
      child: Scaffold(
        // 키보드가 올라와도 화면 크기가 조정되도록 설정
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // 뒤로 가기 버튼 클릭 시 채팅방 나가기 처리 후 화면 종료
              ChatHandler.clearCurrentChatRoom(); // ChatHandler 상태 초기화
              _chatService.leaveChat().then((_) {
                Navigator.of(context).pop();
              });
            },
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: customerImageUrl != null
                    ? NetworkImage(customerImageUrl)
                    : null,
                child: customerImageUrl == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
                backgroundColor: Colors.blue.shade100, // 고객 아바타 색상
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    _customerLabelText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // 팝업 메뉴 위젯 사용
            FriendChatPopupMenu(
              friendsId: widget.friendsId,
              customerId: widget.customerId,
              chatId: _chatId,
            ),
          ],
        ),
        body: SafeArea(
          bottom: false, // 하단 안전 영역 비활성화 (입력 필드가 키보드 위에 완전히 보이도록)
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _refreshReadStatus();
              _dismissKeyboard();
            },
            onPanDown: (_) {
              _refreshReadStatus();
              _dismissKeyboard();
            },
            child: Column(
              children: [
                // 메시지 목록 - Expanded로 감싸서 남은 공간을 모두 차지하도록 함
                Expanded(
                  child: _buildChatMessageList(customerImageUrl),
                ),

                // 채팅 입력 필드
                Container(
                  color: Colors.white, // 배경색 지정
                  child: ChatInputField(
                    controller: _messageController,
                    onSend: _sendMessage,
                    onTap: _refreshReadStatus,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessageList(String? customerImageUrl) {
    // 초기 로딩 중이고 메시지가 없을 때만 로딩 표시
    if (!_initialLoadComplete) {
      return const Center(child: CircularProgressIndicator());
    }

    // 메시지가 없는 경우 - 빈 상태 표시 (초기 로딩 이후)
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _emptyStateTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // 역순 리스트뷰를 위해 메시지 배열 복사 및 역순 정렬
    final reversedMessages = List<ChatMessage>.from(_messages);
    reversedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 26, // 상단 여유 공간 (역순이므로 하단 여유 공간이 됨)
        bottom: 16,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      // 역순 리스트뷰 설정 - 최신 메시지가 맨 아래(화면 처음)에 표시됨
      reverse: true,
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        // 역순이므로 인덱스는 뒤에서부터 계산
        final message = reversedMessages[index];

        // 현재 메시지가 내가 보낸 것인지 확인
        final isMe = message.senderId == widget.friendsId;

        // 날짜 헤더 표시 로직 (역순 리스트뷰이므로 날짜 비교도 반대로)
        final showDateHeader = index == reversedMessages.length - 1 || // 첫 메시지(시간상 가장 오래된 메시지)
            !MessageFormatter.isSameDay(
                reversedMessages[index].timestamp,
                reversedMessages[index + 1].timestamp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDateHeader) ChatDateHeader(timestamp: message.timestamp),
            MessageBubble(
              message: message,
              isMe: isMe,
              customerImage: customerImageUrl,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // 채팅방 나갈 때 상태 초기화
    ChatHandler.clearCurrentChatRoom();

    // 화면이 종료될 때 정리 작업
    _chatService.leaveChat();
    print('채팅 화면 종료');

    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}