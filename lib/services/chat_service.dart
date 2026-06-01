import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/models/user.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatService();

  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];

    // Firestore whereIn limit is 10
    final batches = <Future<List<UserModel>>>[];
    for (var i = 0; i < uids.length; i += 10) {
      final batchIds = uids.sublist(
        i,
        i + 10 > uids.length ? uids.length : i + 10,
      );
      batches.add(
        _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get()
            .then(
              (snap) => snap.docs
                  .map((doc) => UserModel.fromMap(doc.id, doc.data()))
                  .toList(),
            ),
      );
    }

    final results = await Future.wait(batches);
    return results.expand((list) => list).toList();
  }

  Stream<List<Chat>> watchUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];

          final allUids = snapshot.docs
              .expand((doc) => List<String>.from(doc.data()['members'] ?? []))
              .toSet()
              .toList();

          final users = await getUsersByIds(allUids);
          final userMap = {for (final u in users) u.uid: u};

          final chats = snapshot.docs.map((doc) async {
            final data = doc.data();
            final memberIds = List<String>.from(data['members'] ?? []);
            final members = memberIds
                .map((uid) => userMap[uid])
                .whereType<UserModel>() // safely drop any unresolved UIDs
                .toList();

            final lastMessage = await getLastMessage(doc.id);

            return Chat.fromMap(
              uid: doc.id,
              currentUserId: userId,
              data: data,
              members: members,
              messages: lastMessage != null ? [lastMessage] : [],
            );
          }).toList();

          return Future.wait(chats);
        });
  }

  Future<ChatMessage?> getLastMessage(String chatId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty
          ? ChatMessage.fromMap(snapshot.docs.first.data())
          : null;
    } catch (e) {
      return null;
    }
  }

  Stream<List<ChatMessage>> watchChatMessages(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ChatMessage.fromMap(doc.data()))
                .toList(),
          );
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> createChat(List<String> memberIds, bool isGroupChat) async {
    final chatData = {
      'members': memberIds,
      'isGroupChat': isGroupChat,
      'timestamp': DateTime.now(),
    };
    await _firestore.collection('chats').add(chatData);
  }
}
