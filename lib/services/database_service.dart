import 'package:cloud_firestore/cloud_firestore.dart';

const String usersCollection = 'users';
const String chatsCollection = 'chats';
const String messagesCollection = 'messages';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(String uid, String email, String username,
      String imageUrl) async {
    await _firestore.collection(usersCollection).doc(uid).set({
      'email': email,
      'name': username,
      'username': username,
      'image': imageUrl,
      'last_active': DateTime.now(),
      'created_at': DateTime.now(),
    });
  }  
}
