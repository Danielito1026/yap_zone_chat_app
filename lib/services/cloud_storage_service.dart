import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:yap_zone/constants/constants.dart';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadUserImage(String uid, File image) async {
    final storageRef = _storage
        .ref()
        .child(Constants.userImagesCollection)
        .child('$uid.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<({String messageId, String url})> uploadChatImage(String chatId, File image) async {
    final messageId = const Uuid().v4();
    final storageRef = _storage.ref(
      'chats/$chatId/messages/$messageId.jpg',
    );
    await storageRef.putFile(image);
    final url = await storageRef.getDownloadURL();

    return( messageId: messageId, url: url);
  }
}
