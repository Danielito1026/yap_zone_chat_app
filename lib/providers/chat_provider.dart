import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) throw Exception('User not authenticated');
  return ChatService(user.uid);
});

final userChatsProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return Stream.value([]);
  return ref.watch(chatServiceProvider).watchUserChats();
});

final messagesProvider = StreamProvider.family.autoDispose<List<ChatMessage>, String>((
  ref,
  chatId,
) {
  return ref.watch(chatServiceProvider).watchChatMessages(chatId);
});

