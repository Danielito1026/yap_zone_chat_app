import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:yap_zone/services/navigation_service.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

final navigationServiceProvider = Provider<NavigationService>((ref) {
  final key = ref.watch(navigatorKeyProvider);
  return NavigationService(key);
});