import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

const String usersCollection = 'users';

class CloudStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserImage(String uid, File image) async {
    final storageRef = _storage.ref().child('user_images').child('$uid.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  
}