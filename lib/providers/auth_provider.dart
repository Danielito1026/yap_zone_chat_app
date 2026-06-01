import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/providers/database_provider.dart';
import 'package:yap_zone/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value(null);

  print('Current user UID: ${authState}'); // Debug print

  return ref.watch(databaseServiceProvider).watchUserData(authState.uid);
});
