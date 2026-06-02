import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yap_zone/constants/constants.dart';
import 'package:yap_zone/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> fetchAllUsers(UserModel user) async {
    final result = await _firestore
        .collection(Constants.usersCollection)
        .where('email', isNotEqualTo: user.email)
        .get()
        .then(
          (snap) => snap.docs
              .map((doc) => UserModel.fromMap(doc.id, doc.data()))
              .toList(),
        );

    result.forEach((user){
      print(user.email);
    });

    return result;
  }
}
