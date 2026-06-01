import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/models/user.dart';

class Chat {
  final String uid;
  final String currentUserId;
  final bool isActive;
  final bool isGroupChat;
  final List<UserModel> members;
  List<ChatMessage> messages;
  late final List<UserModel> _recipients;

  Chat({
    required this.uid,
    required this.currentUserId,
    required this.isActive,
    required this.isGroupChat,
    required this.members,
    required this.messages,
  }) {
    _recipients = members.where((user) => user.uid != currentUserId).toList();
  }

  List<UserModel> get recipients => _recipients;

  String get displayName => isGroupChat
      ? members.map((u) => u.name).join(', ')
      : recipients.first.name;

  String get displayImage => isGroupChat
      ? 'assets/images/group-chat-logo.png'
      : recipients.first.imageUrl;

  factory Chat.fromMap({
    required String uid,
    required String currentUserId,
    required Map<String, dynamic> data,
    required List<UserModel> members,
    List<ChatMessage>? messages,
  }) {
    return Chat(
      uid: uid,
      currentUserId: currentUserId,
      isActive: data['is_activity'] as bool? ?? false,
      isGroupChat: data['is_group'] as bool? ?? false,
      members: members,
      messages: messages ?? [],
    );
  }
}
