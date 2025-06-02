// lib/chat/controllers/friend_chat_list_controller.dart - 차단 해제 확인 대화상자 부분 수정
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/friend_chat_list_item.dart';
import '../services/friend_chat_list_service.dart';
import '../services/user_management_service.dart';
import '../../services/translation_service.dart';

class FriendChatListController extends ChangeNotifier {
  final String friendsId;
  late final ChatListService _chatListService;
  late final UserManagementService _userManagementService;
  final TranslationService _translationService = TranslationService();

  bool _isLoading = true;
  List<ChatListItem> _chatItems = [];

  // 편집 모드 관련 변수
  bool _isEditMode = false;
  Set<String> _selectedChatIds = {};

  // 텍스트 변수들
  String _unblockSuccessText = '차단이 해제되었습니다';
  String _errorStateText = '오류가 발생했습니다';
  String _confirmUnblockTitle = '차단 해제 확인';
  String _confirmUnblockMessage = '선택한 고객의 차단을 해제하시겠습니까?';
  String _confirmButtonText = '확인';
  String _cancelButtonText = '취소';
  String _blockedChatText = '차단된 채팅';
  String _unblockText = '차단해제';

  // 채팅 목록 실시간 스트림 컨트롤러
  final _chatListStreamController = StreamController<List<ChatListItem>>.broadcast();
  Stream<List<ChatListItem>> get chatListStream => _chatListStreamController.stream;
  StreamSubscription? _chatSubscription;

  FriendChatListController({required this.friendsId}) {
    _chatListService = ChatListService(friendsId: friendsId);
    _userManagementService = UserManagementService();
    _loadTranslations();
  }

  // 번역 텍스트 로드
  Future<void> _loadTranslations() async {
    await _translationService.init();
    _unblockSuccessText = _translationService.get('unblock_success_message', '차단이 해제되었습니다');
    _errorStateText = _translationService.get('error_state', '오류가 발생했습니다');
    _confirmUnblockTitle = _translationService.get('confirm_unblock_title', '차단 해제 확인');
    _confirmUnblockMessage = _translationService.get('confirm_unblock_message', '선택한 고객의 차단을 해제하시겠습니까?');
    _confirmButtonText = _translationService.get('confirm_button', '확인');
    _cancelButtonText = _translationService.get('cancel_button', '취소');
    _blockedChatText = _translationService.get('blocked_chat', '차단된 채팅');
    _unblockText = _translationService.get('unblock_text', '차단해제');
    notifyListeners();
  }

  // Getters
  bool get isLoading => _isLoading;
  List<ChatListItem> get chatItems => _chatItems;
  bool get isEditMode => _isEditMode;
  Set<String> get selectedChatIds => _selectedChatIds;

  // UserManagementService 가져오기
  UserManagementService getService() {
    return _userManagementService;
  }

  // 채팅 목록 로드
  Future<void> loadChatList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final chatItems = await _chatListService.getChatList();

      // 차단된 채팅을 맨 아래로 정렬
      chatItems.sort((a, b) {
        if (a.isBlocked && !b.isBlocked) return 1;
        if (!a.isBlocked && b.isBlocked) return -1;
        return 0;
      });

      _chatItems = chatItems;

      // 스트림에 데이터 추가
      _chatListStreamController.add(_chatItems);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('채팅 목록 로드 오류: $e');
    }
  }

  // 실시간 업데이트 시작
  void startRealTimeUpdates() {
    // 기존 구독이 있으면 취소
    _chatSubscription?.cancel();

    // 채팅 업데이트 스트림 구독
    _chatSubscription = _chatListService.getChatListStream().listen((updatedChatItems) {
      // 차단된 채팅을 맨 아래로 정렬
      updatedChatItems.sort((a, b) {
        if (a.isBlocked && !b.isBlocked) return 1;
        if (!a.isBlocked && b.isBlocked) return -1;
        return 0;
      });

      _chatItems = updatedChatItems;
      _chatListStreamController.add(_chatItems);
      notifyListeners();
    });
  }

  // 편집 모드 토글
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    _selectedChatIds.clear();
    notifyListeners();
  }

  // 채팅 선택/해제
  void toggleChatSelection(String chatId) {
    if (_selectedChatIds.contains(chatId)) {
      _selectedChatIds.remove(chatId);
    } else {
      _selectedChatIds.add(chatId);
    }
    notifyListeners();
  }

  // 채팅 체크박스 변경
  void setChatSelection(String chatId, bool isSelected) {
    if (isSelected) {
      _selectedChatIds.add(chatId);
    } else {
      _selectedChatIds.remove(chatId);
    }
    notifyListeners();
  }

  // 선택된 채팅 삭제
  Future<void> deleteSelectedChats() async {
    if (_selectedChatIds.isEmpty) return;

    try {
      // 각 선택된 채팅에 대해 삭제 작업 수행
      for (final chatId in _selectedChatIds) {
        await _chatListService.deleteChat(chatId);
      }

      // 목록 새로고침
      await loadChatList();

      // 편집 모드 종료
      _isEditMode = false;
      _selectedChatIds.clear();
      notifyListeners();
    } catch (e) {
      print('채팅 삭제 중 오류가 발생했습니다: $e');
    }
  }

  // 차단된 채팅 있는지 확인
  bool hasBlockedChats() {
    final blockedChats = _selectedChatIds
        .map((id) => _chatItems.firstWhere((item) => item.chatId == id))
        .where((item) => item.isBlocked)
        .toList();

    return blockedChats.isNotEmpty;
  }

  // 선택된 차단된 채팅 차단 해제
  Future<void> unblockSelectedChats(BuildContext context) async {
    if (_selectedChatIds.isEmpty) return;

    try {
      // 차단 해제 확인 대화상자 표시
      final bool confirm = await _showUnblockConfirmDialog(context);
      if (!confirm) return;

      // 각 선택된 채팅에 대해 차단 해제 작업 수행
      for (final chatId in _selectedChatIds) {
        // chatId에서 해당 고객 ID 찾기
        final selectedChat = _chatItems.firstWhere(
              (item) => item.chatId == chatId,
          orElse: () => throw Exception('채팅을 찾을 수 없습니다'),
        );

        if (selectedChat.isBlocked) {
          await _userManagementService.unblockUser(
              friendsId,
              selectedChat.customerId
          );
        }
      }

      // 성공 메시지 출력
      print(_unblockSuccessText);

      // 목록 새로고침
      await loadChatList();

      // 편집 모드 종료
      _isEditMode = false;
      _selectedChatIds.clear();
      notifyListeners();
    } catch (e) {
      print('$_errorStateText: $e');
    }
  }

  // 차단 해제 확인 대화상자
  Future<bool> _showUnblockConfirmDialog(BuildContext context) async {
    bool result = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.block, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _confirmUnblockTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          content: Text(
            _confirmUnblockMessage,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = false;
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _cancelButtonText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _confirmButtonText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );

    return result;
  }

  // 단일 채팅 차단 해제 처리
  Future<void> handleUnblockChat(BuildContext context, String customerId) async {
    try {
      // 차단 해제 확인 다이얼로그 표시
      final bool confirm = await _showSingleUnblockConfirmDialog(context, customerId);
      if (!confirm) return;

      // 차단 해제 처리
      await _userManagementService.unblockUser(friendsId, customerId);

      // 성공 메시지 출력
      print(_unblockSuccessText);

      // 목록 새로고침
      await loadChatList();
    } catch (e) {
      print('채팅 차단 해제 중 오류 발생: $e');
    }
  }

  // 단일 차단 해제 확인 대화상자
  Future<bool> _showSingleUnblockConfirmDialog(BuildContext context, String customerId) async {
    bool result = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.block, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _confirmUnblockTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          content: Text(
            _confirmUnblockMessage,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = false;
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _cancelButtonText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                result = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[900],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _confirmButtonText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        );
      },
    );

    return result;
  }

  @override
  void dispose() {
    // 리소스 해제
    _chatSubscription?.cancel();
    _chatListStreamController.close();
    super.dispose();
  }
}