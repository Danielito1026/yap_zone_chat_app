import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/pages/auth_page.dart';
import 'package:yap_zone/pages/splash_page.dart';
import 'package:yap_zone/providers/navigator_provider.dart';
import 'package:yap_zone/routes/router.dart';
import 'package:yap_zone/widgets/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    return MaterialApp(
      title: 'Yap Zone',
      navigatorKey: navigatorKey,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.signIn: (context) =>
            const AuthPage(authMode: AuthMode.signIn),
        AppRoutes.signUp: (context) =>
            const AuthPage(authMode: AuthMode.signUp),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontVariations: [FontVariation('wght', 700)]),
          displayMedium: TextStyle(
            fontVariations: [FontVariation('wght', 700)],
          ),
          displaySmall: TextStyle(fontVariations: [FontVariation('wght', 700)]),
          headlineLarge: TextStyle(
            fontVariations: [FontVariation('wght', 700)],
          ),
          headlineMedium: TextStyle(
            fontVariations: [FontVariation('wght', 600)],
          ),
          headlineSmall: TextStyle(
            fontVariations: [FontVariation('wght', 600)],
          ),
          titleLarge: TextStyle(fontVariations: [FontVariation('wght', 600)]),
          titleMedium: TextStyle(fontVariations: [FontVariation('wght', 500)]),
          titleSmall: TextStyle(fontVariations: [FontVariation('wght', 500)]),
          bodyLarge: TextStyle(fontVariations: [FontVariation('wght', 400)]),
          bodyMedium: TextStyle(fontVariations: [FontVariation('wght', 400)]),
          bodySmall: TextStyle(fontVariations: [FontVariation('wght', 400)]),
          labelLarge: TextStyle(fontVariations: [FontVariation('wght', 500)]),
          labelMedium: TextStyle(fontVariations: [FontVariation('wght', 400)]),
          labelSmall: TextStyle(fontVariations: [FontVariation('wght', 400)]),
        ),
        colorSchemeSeed: const Color.fromARGB(255, 36, 35, 49),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 24),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 30, 29, 37),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: AuthGate(),
    );
  }
}
