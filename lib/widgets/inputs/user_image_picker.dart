import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/media_provider.dart';

class UserImagePicker extends ConsumerStatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  ConsumerState<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends ConsumerState<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    final pickedFile = await ref.read(mediaServiceProvider).pickImage();
    if (pickedFile == null) return;
    final image = File(pickedFile.path!);
    setState(() => _pickedImage = image);
    widget.onPickImage(image);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: const Color.fromARGB(255, 30, 29, 37),
          foregroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}
