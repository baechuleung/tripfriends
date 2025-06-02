// lib/chat/screens/friend_chat_list_screen.dart - 트립프렌즈 앱(프렌즈용)
import 'package:flutter/material.dart';
import '../models/friend_chat_list_item.dart';
import '../controllers/friend_chat_list_controller.dart';
import 'friend_chat_screen.dart';
import '../../services/translation_service.dart';

class ChatListScreen extends StatefulWidget {
  final String friendsId;

  const ChatListScreen({
    Key? key,
    required this.friendsId,
  }) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late FriendChatListController _controller;
  final TranslationService _translationService = TranslationService();

  bool _isLoading = true;
  List<ChatListItem> _chatItems = [];
  bool _isEditMode = false;
  Set<String> _selectedChatIds = {};

  // 번역 텍스트 변수들
  String _chatListTitle = '채팅 리스트';
  String _emptyChatListText = '아직 채팅이 없습니다';
  String _deleteButtonText = '삭제하기';
  String _unblockButtonText = '차단 해제하기';
  String _blockedChatText = '차단된 채팅';
  String _unblockText = '차단해제';

  @override
  void initState() {
    super.initState();
    _controller = FriendChatListController(friendsId: widget.friendsId);
    _controller.addListener(_updateState);
    _initTranslations();
    _loadChatList();
    _controller.startRealTimeUpdates(); // 실시간 업데이트 시작
  }

  // 번역 로드 함수
  Future<void> _initTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {
        _chatListTitle = _translationService.get('chat_list_title', '채팅 리스트');
        _emptyChatListText = _translationService.get('empty_chat_list', '아직 채팅이 없습니다');
        _deleteButtonText = _translationService.get('delete_button', '삭제하기');
        _unblockButtonText = _translationService.get('unblock_button', '차단 해제하기');
        _blockedChatText = _translationService.get('blocked_chat', '차단된 채팅');
        _unblockText = _translationService.get('unblock_text', '차단해제');
      });
    }
  }

  void _loadChatList() async {
    await _controller.loadChatList();
    _updateState();
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _isLoading = _controller.isLoading;
        _chatItems = _controller.chatItems;
        _isEditMode = _controller.isEditMode;
        _selectedChatIds = _controller.selectedChatIds;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 부분 (타이틀과 카운트, 편집 버튼)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _chatListTitle,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF353535)
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF237AFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_chatItems.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 편집 아이콘 (연필)
                  if (_chatItems.isNotEmpty)
                    GestureDetector(
                      onTap: () => _controller.toggleEditMode(),
                      child: Icon(
                        _isEditMode ? Icons.close : Icons.edit,
                        color: const Color(0xFF353535),
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),

            // 채팅 목록
            Expanded(
              child: _buildChatList(),
            ),

            // 삭제 및 차단 해제 버튼 (편집 모드일 때만 표시)
            if (_isEditMode && _selectedChatIds.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _controller.hasBlockedChats() // 차단된 채팅이 있으면 두 버튼 같이 표시
                    ? Row(
                  children: [
                    // 차단 해제 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _controller.unblockSelectedChats(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                          foregroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _unblockButtonText,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 삭제 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _controller.deleteSelectedChats(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _deleteButtonText,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                )
                    : ElevatedButton( // 차단된 채팅이 없으면 삭제 버튼만 표시
                  onPressed: () => _controller.deleteSelectedChats(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _deleteButtonText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<List<ChatListItem>>(
      stream: _controller.chatListStream,
      builder: (context, snapshot) {
        // 로딩 중이면 로딩 표시
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 데이터가 없으면 안내 메시지
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              _emptyChatListText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }

        // 데이터가 있으면 목록 표시
        _chatItems = snapshot.data!; // 로컬 변수 업데이트

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: _chatItems.length,
          itemBuilder: (context, index) {
            final item = _chatItems[index];
            return _buildChatListItem(item);
          },
        );
      },
    );
  }

  Widget _buildChatListItem(ChatListItem item) {
    final bool isSelected = _selectedChatIds.contains(item.chatId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (_isEditMode) {
            // 편집 모드에서는 선택/해제
            _controller.toggleChatSelection(item.chatId);
          } else {
            // 차단된 채팅은 열지 않음
            if (item.isBlocked) return;

            // 채팅 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  friendsId: widget.friendsId,
                  customerId: item.customerId,
                  customerName: item.customerName,
                  customerImage: item.customerImage,
                ),
              ),
            ).then((_) {
              // 채팅 화면에서 돌아왔을 때 목록 갱신
              _controller.loadChatList();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 체크박스 (편집 모드일 때만)
              if (_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        _controller.setChatSelection(item.chatId, value == true);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: const Color(0xFF237AFF),
                    ),
                  ),
                ),

              // 프로필 이미지
              CircleAvatar(
                radius: 24,
                backgroundImage: item.customerImage != null
                    ? NetworkImage(item.customerImage!)
                    : null,
                child: item.customerImage == null
                    ? const Icon(Icons.person)
                    : null,
                backgroundColor: Colors.blue.shade100,
              ),
              const SizedBox(width: 14),

              // 채팅 정보 (이름, 메시지, 타임스탬프)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 고객 이름 및 정보 영역
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 고객 이름
                              Text(
                                item.customerName,
                                style: TextStyle(
                                  fontWeight: item.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 15,
                                  color: item.isBlocked ? Colors.grey : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 마지막 메시지
                              Text(
                                item.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: item.isBlocked
                                      ? Colors.grey
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 차단 해제 버튼 또는 시간/읽지 않은 메시지
                        if (item.isBlocked && !_isEditMode)
                        // 차단 해제 버튼 (차단된 채팅만)
                          Container(
                            width: 75, // 버튼 너비 설정
                            height: 50, // 버튼 높이 설정
                            margin: const EdgeInsets.only(left: 8),
                            child: Material(
                              color: Colors.red, // 빨간색 배경
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  _controller.handleUnblockChat(context, item.customerId);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Center(
                                  child: Text(
                                    _unblockText,
                                    style: const TextStyle(
                                      color: Colors.white, // 흰색 글자
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                        // 시간 및 읽지 않은 메시지 수
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // 타임스탬프
                              Text(
                                item.formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 읽지 않은 메시지 수 또는 빈 공간
                              item.unreadCount > 0 && !item.isBlocked && !_isEditMode
                                  ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : const SizedBox(height: 20), // 빈 공간 유지
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}