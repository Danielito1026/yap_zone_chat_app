import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yap_zone/models/user.dart';

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

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data() ?? {});
    }
    return null;
  }

  Stream<UserModel?> watchUserData(String uid) {
    final result= _firestore
      .collection(usersCollection)
      .doc(uid)
      .snapshots()
      .map(
        (snapshot) => snapshot.exists
            ? UserModel.fromMap(snapshot.id, snapshot.data()!)
            : null,
      );

    result.listen((user) {
      print('User data updated for UID: $uid, UserModel: $user'); // Debug print
    });

    return result;
  }
  

  Future<void> updateUserActivity(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).update({
      'last_active': DateTime.now(),
    });
  }
}
