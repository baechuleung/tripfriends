// lib/chat/models/friend_chat_list_item.dart - 트립프렌즈 앱(프렌즈용)
class ChatListItem {
  final String chatId;           // 채팅방 ID
  final String customerId;       // 고객 ID
  final String customerName;     // 고객 이름
  final String? customerImage;   // 고객 프로필 이미지 URL
  final String lastMessage;      // 마지막 메시지 내용
  final String formattedTime;    // 포맷팅된 시간 문자열
  final int timestamp;           // 원본 타임스탬프 (밀리초)
  final int unreadCount;         // 읽지 않은 메시지 수
  final bool isBlocked;          // 차단 여부

  ChatListItem({
    required this.chatId,
    required this.customerId,
    required this.customerName,
    this.customerImage,
    required this.lastMessage,
    required this.formattedTime,
    required this.timestamp,
    required this.unreadCount,
    required this.isBlocked,
  });

  // 프로필 이미지가 있는지 확인
  bool get hasProfileImage => customerImage != null && customerImage!.isNotEmpty;

  // 읽지 않은 메시지가 있는지 확인
  bool get hasUnreadMessages => unreadCount > 0;
}