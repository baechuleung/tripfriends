// lib/chat/widgets/friend_chat_popup_menu.dart
import 'package:flutter/material.dart';
import '../widgets/report_block_dialog.dart';
import '../services/user_management_service.dart';
import '../../services/translation_service.dart';

class FriendChatPopupMenu extends StatefulWidget {
  final String friendsId;
  final String customerId;
  final String chatId;

  const FriendChatPopupMenu({
    Key? key,
    required this.friendsId,
    required this.customerId,
    required this.chatId,
  }) : super(key: key);

  @override
  State<FriendChatPopupMenu> createState() => _FriendChatPopupMenuState();
}

class _FriendChatPopupMenuState extends State<FriendChatPopupMenu> {
  final TranslationService _translationService = TranslationService();
  late final UserManagementService _userManagementService;

  // 번역된 텍스트 변수들
  String _reportSuccessText = '신고가 접수되었습니다';
  String _blockSuccessText = '사용자가 차단되었습니다';
  String _reportMenuText = '신고하기';
  String _blockMenuText = '차단하기';
  String _errorStateText = '오류가 발생했습니다';

  @override
  void initState() {
    super.initState();
    _userManagementService = UserManagementService();
    _loadTranslations();
  }

  // 번역 로드
  Future<void> _loadTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {
        _reportSuccessText = _translationService.get('report_success_message', '신고가 접수되었습니다');
        _blockSuccessText = _translationService.get('block_success_message', '사용자가 차단되었습니다');
        _reportMenuText = _translationService.get('report_menu_option', '신고하기');
        _blockMenuText = _translationService.get('block_menu_option', '차단하기');
        _errorStateText = _translationService.get('error_state', '오류가 발생했습니다');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Colors.white,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'report',
            child: Center(
              child: Text(_reportMenuText),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'block',
            child: Center(
              child: Text(_blockMenuText),
            ),
          ),
        ];
      },
      onSelected: (String value) {
        if (value == 'report') {
          _showReportDialog(context);
        } else if (value == 'block') {
          _showBlockDialog(context);
        }
      },
    );
  }

  // 신고하기 다이얼로그 표시
  void _showReportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ReportDialog(
          onReport: (String reason, String? customReason) async {
            Navigator.of(dialogContext).pop();

            try {
              // 사용자 관리 서비스의 reportUser 메서드 호출
              await _userManagementService.reportUser(
                reporterId: widget.friendsId,
                reportedUserId: widget.customerId,
                reason: reason,
                customReason: customReason,
              );

              // 성공 메시지 - 스낵바 대신 디버그 프린트로 변경
              print(_reportSuccessText);
            } catch (e) {
              // 오류 메시지 - 스낵바 대신 디버그 프린트로 변경
              print('$_errorStateText: $e');
            }
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  // 차단하기 다이얼로그 표시
  void _showBlockDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlockDialog(
          onBlock: () async {
            Navigator.of(dialogContext).pop();

            try {
              // 사용자 관리 서비스의 blockUser 메서드 호출
              await _userManagementService.blockUser(
                blockerId: widget.friendsId,
                blockedUserId: widget.customerId,
                chatId: widget.chatId,
              );

              // 성공 메시지 - 스낵바 대신 디버그 프린트로 변경
              print(_blockSuccessText);

              // 차단 후 이전 화면으로 이동
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              });
            } catch (e) {
              // 오류 메시지 - 스낵바 대신 디버그 프린트로 변경
              print('$_errorStateText: $e');
            }
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}