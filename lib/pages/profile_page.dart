import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/widgets/rounded_image_avatar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  // Placeholder for edit mode state
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          spacing: 16,
          children: [
            // Header with cover and avatar
            _buildHeaderSection(user!),
            // Profile info section
            _buildInfoSection(user),
            // Action buttons
            if (!_isEditing) _buildActionButtons(),
            if (_isEditing) _buildEditActions(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Error loading user data'),
    );
  }

  Widget _buildHeaderSection(UserModel user) {
    return RoundedImageAvatar(
      avatarUrl: user.imageUrl,
      isGroupChat: false,
      isActive: true,
      radius: 50,
      indicatorSize: 16,
    );
  }

  Widget _buildInfoSection(UserModel user) {
    return Column(
      children: [
        Text(
          user.username,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(user.email, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () {}, child: Text('Edit Profile')),
        const SizedBox(width: 16),
        ElevatedButton(onPressed: () {}, child: Text('Settings')),
      ],
    );
  }

  Widget _buildEditActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () {}, child: Text('Save Changes')),
        const SizedBox(width: 16),
        ElevatedButton(onPressed: () {}, child: Text('Cancel')),
      ],
    );
  }
}
