import 'package:yap_zone/constants/constants.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/services/database_service.dart';

class UserService {
  late final GenericDatabaseService<UserModel> _dbService;

  UserService() {
    _dbService = GenericDatabaseService<UserModel>(
      collectionName: Constants.usersCollection,
      fromMap: (id, data) => UserModel.fromMap(id, data),
      toMap: (user) => user.toMap(),
    );
  }

  Future<List<UserModel>> fetchAllUsers(UserModel user) async {
    final users = await _dbService.getDocumentsWhere(
      field: 'email',
      isNotEqualTo: user.email,
    );
    return users;
  }

  Future<UserModel?> getUserById(String uid) async {
    return await _dbService.getDocument(uid);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _dbService.watchDocument(uid);
  }

  Future<void> saveUserData(
    String uid,
    String email,
    String username,
    String imageUrl,
  ) async {
    await _dbService.setDocument(
      uid,
      UserModel(
        name: username,
        username: username,
        email: email,
        imageUrl: imageUrl,
      ),
    );
  }


  Future<void> updateUserActivity(String uid) async {
    await _dbService.updateDocument(uid, {'last_active': DateTime.now(),});
  }
}
