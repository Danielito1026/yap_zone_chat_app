import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/pages/auth_page.dart';
import 'package:yap_zone/pages/splash_page.dart';
import 'package:yap_zone/providers/auth_provider.dart';
import 'package:yap_zone/widgets/main_shell.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _minimumSplashTimePassed = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _minimumSplashTimePassed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Always show splash until minimum duration passes
    if (!_minimumSplashTimePassed) {
      return const SplashPage();
    }
    
    return authState.when(
      data: (user) => user != null
          ? const MainShell()
          : const AuthPage(authMode: AuthMode.signIn),
      loading: () => SplashPage(),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
    );
  }
}
