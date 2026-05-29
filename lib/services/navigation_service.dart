import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationService(this.navigatorKey);

  Future<void> popAndNavigateToRoute(
    String routeName, {
    Object? arguments,
  }) async {
    await navigatorKey.currentState?.popAndPushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<void> navigateToRoute(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  Future<void> navigateToReplacementRoute(
    String routeName, {
    Object? arguments,
  }) async {
    await navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<void> navigateToPage(Widget page) async {
    await navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> navigateToReplacementPage(Widget page) async {
    await navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
