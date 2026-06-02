import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/providers/cloud_storage_provider.dart';
import 'package:yap_zone/services/chat_service.dart';


final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final userChatsProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return Stream.value([]);
  return ref.watch(chatServiceProvider).watchUserChats(user.uid);
});

final messagesProvider = StreamProvider.family
    .autoDispose<List<ChatMessage>, String>((ref, chatId) {
      return ref.watch(chatServiceProvider).watchChatMessages(chatId);
    });

class ChatActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMessageText(String chatId, String messageText) async {
    final user = ref.read(currentUserProvider).value;

    final message = ChatMessage(
      senderId: user!.uid,
      content: messageText,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
    await ref.read(chatServiceProvider).sendMessage(chatId, message);
  }

  Future<void> sendMessageImage(String chatId, File image) async {
    final user = ref.read(currentUserProvider).value;

    final result = await ref
        .read(cloudStorageServiceProvider)
        .uploadChatImage(chatId, image);

    final message = ChatMessage(
      senderId: user!.uid,
      content: result.url,
      type: MessageType.image,
      timestamp: DateTime.now(),
    );

    await ref
        .read(chatServiceProvider)
        .sendMessageImage(chatId, result.messageId, message);
  }

  Future<void> leaveChat(Chat chat) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      return;
    }
    final updatedMemberUIDs = chat.members
        .where((member) => member.uid != user.uid)
        .map((member) => member.uid)
        .toList();
    await ref.read(chatServiceProvider).updateChatData(chat.uid, {
      'members': updatedMemberUIDs,
    });
  }

  Future<void> deleteChat(String chatId) async {
    await ref.read(chatServiceProvider).deleteChat(chatId);
  }
}

final chatActionProvider = AsyncNotifierProvider<ChatActionNotifier, void>(
  () => ChatActionNotifier(),
);
