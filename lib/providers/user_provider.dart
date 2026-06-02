import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class UsersNotifier extends AsyncNotifier<List<UserModel>> {
  @override
  Future<List<UserModel>> build() async {
    final user = ref.read(currentUserProvider).value;
    return await ref.read(userServiceProvider).fetchAllUsers(user!);
  }

  
}

final usersProvider =
    AsyncNotifierProvider.autoDispose<UsersNotifier, List<UserModel>>(
      () => UsersNotifier(),
    );

final filteredUsersProvider = Provider<List<UserModel>>((ref) {
  final users = ref.watch(usersProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return users;

  return users
      .where(
        (user) =>
            user.username.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.name.toLowerCase().contains(query),
      )
      .toList();
});
