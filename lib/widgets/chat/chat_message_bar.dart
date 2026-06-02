import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/chat_provider.dart';
import 'package:yap_zone/providers/media_provider.dart';

class ChatMessageBar extends ConsumerStatefulWidget {
  const ChatMessageBar({super.key, required this.chatId});

  final String chatId;

  @override
  ConsumerState<ChatMessageBar> createState() => _ChatMessageBarState();
}

class _ChatMessageBarState extends ConsumerState<ChatMessageBar> {
  late double _deviceHeight;
  late double _deviceWidth;

  final TextEditingController _messageEditingController =
      TextEditingController();
  File? _pickedImage;
  bool isSending = false;

  @override
  void dispose() {
    super.dispose();
    _messageEditingController.dispose();
    _deleteTempImage();
  }

  Future<void> _deleteTempImage() async {
    if (_pickedImage != null) {
      try {
        await _pickedImage!.delete();
      } catch (e) {
        // Log error but don't crash
        debugPrint('Failed to delete temp image: $e');
      }
    }
  }

  void _pickImage() async {
    final pickedFile = await ref.read(mediaServiceProvider).pickImage();
    if (pickedFile == null) return;
    await _deleteTempImage();
    final image = File(pickedFile.path!);
    setState(() => _pickedImage = image);
  }

  void _submitMessage() async {
    setState(() {
      isSending = true;
    });
    try {
      final chatAction = ref.read(chatActionProvider.notifier);

      if (_pickedImage != null) {
        final file = _pickedImage;
        await chatAction.sendMessageImage(widget.chatId, file!);
        await _deleteTempImage();
        setState(() {
          _pickedImage = null;
        });
      }

      final message = _messageEditingController.text;
      _messageEditingController.clear();

      if (message.trim().isEmpty) {
        return;
      }

      await chatAction.sendMessageText(widget.chatId, message);
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _pickedImage != null
              ? Container(
                  padding: EdgeInsets.all(8),
                  width: _deviceWidth * .60,
                  height: _deviceHeight * 0.35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_pickedImage!, fit: BoxFit.cover),
                  ),
                )
              : Expanded(
                  child: TextField(
                    controller: _messageEditingController,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: InputDecoration(
                      hint: Text('Type a message'),
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                    ),
                  ),
                ),
          IconButton(
            onPressed: isSending ? null : _submitMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton.filled(
            onPressed: _pickImage,
            icon: Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
