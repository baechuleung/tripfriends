// lib/chat/models/friend_chat_message.dart
class ChatMessage {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  // Firebase에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  // Firebase에서 가져온 데이터로 객체 생성
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }

  // 읽음 상태 업데이트한 새 메시지 생성
  ChatMessage copyWithReadStatus(bool read) {
    return ChatMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: timestamp,
      isRead: read,
    );
  }
}