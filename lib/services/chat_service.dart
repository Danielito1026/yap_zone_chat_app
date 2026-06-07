import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yap_zone/constants/constants.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/services/database_service.dart';

class ChatServiceV2 {
  late final DatabaseService<Chat> _chatService;
  final UserModel currentUser;
  ChatServiceV2(this.currentUser) {
    _chatService = DatabaseService<Chat>(
      collectionName: Constants.chatsCollection,
      fromMap: (id, data) => Chat.fromMap(
        id,
        currentUserId: currentUser.uid,
        data: data,
        messages: [],
      ),
      toMap: (chat) => chat.toMap(), // Add toMap to Chat model
    );
  }

  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];

    final userService = DatabaseService<UserModel>(
      collectionName: Constants.usersCollection,
      fromMap: (id, data) => UserModel.fromMap(id, data),
      toMap: (user) => user.toMap(),
    );

    final users = <UserModel>[];
    for (var i = 0; i < uids.length; i += 10) {
      final batchIds = uids.sublist(
        i,
        i + 10 > uids.length ? uids.length : i + 10,
      );
      final batchUsers = await userService.getDocumentsWhere(
        field: FieldPath.documentId,
        whereIn: batchIds,
      );
      users.addAll(batchUsers);
    }

    return users;
  }

  Stream<List<Chat>> watchUserChats(String userId) {
    return _chatService
        .watchDocumentsWhere(field: 'members', arrayContains: userId)
        .asyncMap((chats) async {
          final allUids = chats
              .expand((chat) => chat.membersId)
              .toSet()
              .toList();

          final users = await getUsersByIds(allUids);
          final userMap = {for (final u in users) u.uid: u};
          final completedChats = chats.map((chat) async {
            final members = chat.membersId
                .map((uid) => userMap[uid])
                .whereType<UserModel>() // safely drop any unresolved UIDs
                .toList();

            final lastMessage = await getLastMessage(chat.uid);

            final message = lastMessage != null
                ? (lastMessage.type == MessageType.text
                      ? lastMessage
                      : ChatMessage(
                          senderId: lastMessage.senderId,
                          type: lastMessage.type,
                          content:
                              '${lastMessage.senderId == currentUser.uid ? "You" : userMap[lastMessage.senderId]?.username ?? "Someone"} sent an image',
                          timestamp: lastMessage.timestamp,
                        ))
                : null;

            return Chat(
              uid: chat.uid,
              currentUserId: userId,
              isActive: chat.isActive,
              isGroupChat: chat.isGroupChat,
              members: members,
              messages: lastMessage != null
                  ? [message].whereType<ChatMessage>().toList()
                  : [],
            );
          }).toList();
          return Future.wait(completedChats);
        });
  }

  Future<Chat?> getChatById(String chatId) async {
    final chat = await _chatService.getDocument(chatId);
    if (chat == null) return null;

    final users = await getUsersByIds(chat.membersId);
    final userMap = {for (final u in users) u.uid: u};

    final members = chat.membersId
        .map((uid) => userMap[uid])
        .whereType<UserModel>()
        .toList();

    return Chat(
      uid: chat.uid,
      currentUserId: currentUser.uid,
      isActive: chat.isActive,
      isGroupChat: chat.isGroupChat,
      members: members,
      messages: [], // Messages can be loaded separately
    );
  }

  Future<ChatMessage?> getLastMessage(String chatId) async {
    final snapshot = await _chatService
        .subcollection(
          docId: chatId,
          subcollectionName: Constants.messagesCollection,
        )
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty
        ? ChatMessage.fromMap(snapshot.docs.first.data())
        : null;
  }

  Stream<List<ChatMessage>> watchChatMessages(String chatId) {
    return _chatService
        .subcollection(
          docId: chatId,
          subcollectionName: Constants.messagesCollection,
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<String?> createChat(List<String> memberIds) async {
    return await _chatService.addDocument(
      Chat(
        isActive: false,
        isGroupChat: memberIds.length > 2,
        membersId: memberIds,
      ),
    );
  }

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    try {
      final messageService = DatabaseService<ChatMessage>(
        collectionName: Constants.chatsCollection,
        subcollectionName: Constants.messagesCollection,
        fromMap: (id, data) => ChatMessage.fromMap(data),
        toMap: (msg) => msg.toMap(),
      );

      await messageService.addDocumentToSubcollection(chatId, message);
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessageImage(
    String chatId,
    String messageId,
    ChatMessage message,
  ) async {
    await _chatService
        .subcollection(
          docId: chatId,
          subcollectionName: Constants.messagesCollection,
        )
        .doc(messageId)
        .set(message.toMap());
  }

  Future<void> updateChatData(String chatId, Map<String, dynamic> data) async {
    await _chatService.updateDocument(chatId, data);
  }

  Future<void> deleteChat(String chatId) async {
    await _chatService.deleteDocument(chatId);
  }
}
