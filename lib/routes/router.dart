import 'package:flutter/material.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/pages/chat_page.dart';

class AppRoutes {
  static const String home = '/chats';
  static const String signIn = '/auth/sign-in';
  static const String signUp = '/auth/sign-up';
  static const String splash = '/splash';
  static const String users = '/users';
  static const String profile = '/profile';
  static void openChat(BuildContext context, Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(chat: chat),
        settings: RouteSettings(name: '/chats/${chat.uid}'),
      ),
    );
  }
}
