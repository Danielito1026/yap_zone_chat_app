import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, unknown }

class ChatMessage {
  final String senderId;
  final MessageType type;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.type,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'type': type.toString().split('.').last ,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['sender_id'] as String? ?? '',
      type: _messageTypeFromString(
        map['type'] as String? ?? 'unknown',
      ),
      content: map['content'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static MessageType _messageTypeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.unknown;
    }
  }
}
