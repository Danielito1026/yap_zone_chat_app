import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Center(
      child: Column(
        children: [
          Text('Profile Page'),
          userAsync.when(
            data: (user) => Text('Hello, ${user?.username ?? 'Guest'}!'),
            loading: () => CircularProgressIndicator(),
            error: (e, st) => Text('Error loading user data'),
          ),
        ],
      ),
    );
  }
}
