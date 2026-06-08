import 'package:yap_zone/constants/constants.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/services/database_service.dart';

class UserService {
  late final DatabaseService<UserModel> _dbService;

  UserService() {
    _dbService = DatabaseService<UserModel>(
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
    String imageUrl, {
    bool isCreate = false,
  }) async {
    final model = UserModel(
      name: username,
      username: username,
      email: email,
      imageUrl: imageUrl,
    );
    await _dbService.setDocumentMap(
      uid,
      model.toMap(includeCreatedAt: isCreate),
    );
  }

  Future<void> updateUserActivity(String uid) async {
    await _dbService.updateDocument(uid, {'last_active': DateTime.now()});
  }
}
