import 'package:uuid/uuid.dart';
import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/models/user.dart';

class Chat {
  final String uid;
  final String currentUserId;
  final bool isActive;
  final bool isGroupChat;
  List<String> membersId;
  List<UserModel> members;
  List<ChatMessage> messages;
  late final List<UserModel> _recipients;

  Chat({
    String? uid,
    String? currentUserId,
    required this.isActive,
    required this.isGroupChat,
    this.membersId = const [],
    this.members = const [],
    this.messages = const [],
  }) : uid = uid ?? Uuid().v4(),
       currentUserId = currentUserId ?? '' {
    _recipients = members.where((user) => user.uid != currentUserId).toList();
  }

  List<UserModel> get recipients => _recipients;

  String get displayName => isGroupChat
      ? members.map((u) => u.username).join(', ')
      : recipients.first.username;

  String get displayImage => isGroupChat
      ? 'assets/images/group-chat-logo.png'
      : recipients.first.imageUrl;

  factory Chat.fromMap(
    String uid, {
    required String currentUserId,
    required Map<String, dynamic> data,
    List<ChatMessage>? messages,
  }) {
    return Chat(
      uid: uid,
      currentUserId: currentUserId,
      isActive: data['is_activity'] as bool? ?? false,
      isGroupChat: data['is_group'] as bool? ?? false,
      membersId: List<String>.from(data['members'] ?? []),
      messages: messages ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_group': isGroupChat,
      'is_activity': isActive,
      'members': membersId,
    };
  }

  Chat copyWith({
    String? uid,
    String? currentUserId,
    bool? isActive,
    bool? isGroupChat,
    List<UserModel>? members,
    List<ChatMessage>? messages,
  }) {
    return Chat(
      uid: uid ?? this.uid,
      currentUserId: currentUserId ?? this.currentUserId,
      isActive: isActive ?? this.isActive,
      isGroupChat: isGroupChat ?? this.isGroupChat,
      members: members ?? this.members,
      messages: messages ?? this.messages,
    );
  }
}
