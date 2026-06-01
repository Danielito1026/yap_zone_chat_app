import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

const String usersCollection = 'users';
const String chatsCollection = 'chats';
const String messagesCollection = 'messages';
const String userImagesCollection = 'user_images';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserImage(String uid, File image) async {
    final storageRef = _storage.ref().child(userImagesCollection).child('$uid.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  
}