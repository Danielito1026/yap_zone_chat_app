import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/providers/chat_provider.dart';
import 'package:yap_zone/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class UsersNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  Future<List<UserModel>> build() async {
    final authState = ref.watch(authStateProvider);

    final userStream = authState.value;
    if (userStream == null) {
      return [];
    }

    final user = await ref
        .watch(userServiceProvider)
        .getUserById(userStream.uid);

    if (user == null) {
      return [];
    }

    return await ref.read(userServiceProvider).fetchAllUsers(user);
  }
}

final usersProvider =
    AsyncNotifierProvider.autoDispose<UsersNotifier, List<UserModel>>(
      () => UsersNotifier(),
    );

class UserActionNotifier extends Notifier<List<UserModel>> {
  @override
  List<UserModel> build() {
    return [];
  }

  Future<String?> createChat() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return null;

    return await ref.read(chatServiceV2Provider).createChat([
      ...state.map((user) => user.uid),
      user.uid,
    ]);
  }

  void setUsers(UserModel users) {
    state = [...state, users];
  }

  void clearUsers() {
    state = [];
  }

  void removeUser(String uid) {
    state = state.where((user) => user.uid != uid).toList();
  }
}

final userActionProvider =
    NotifierProvider.autoDispose<UserActionNotifier, List<UserModel>>(
      () => UserActionNotifier(),
    );
