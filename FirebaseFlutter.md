# Flutter + Firebase Integration Guide

A practical, battle-tested blueprint for building a Flutter app with Firebase — covering Riverpod state management, Firebase Auth, Firestore, Storage, and FCM push notifications. This guide is based on real project experience, including workarounds for known build issues.

---

## Table of Contents

1. [Dependencies](#1-dependencies)
2. [One-Time Firebase CLI Setup](#2-one-time-firebase-cli-setup)
3. [Platform Configuration & Initialization](#3-platform-configuration--initialization)
4. [Application Architecture (Riverpod + Auth)](#4-application-architecture-riverpod--auth)
5. [Image Handling (Picker + Firebase Storage)](#5-image-handling-picker--firebase-storage)
6. [Push Notifications (FCM)](#6-push-notifications-fcm)
7. [Firestore Security Rules](#7-firestore-security-rules)
8. [Troubleshooting Android Build Errors](#8-troubleshooting-android-build-errors)
9. [iOS-Specific Setup](#9-ios-specific-setup)

---

## 1. Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase Core & Auth
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0

  # Database & Storage
  cloud_firestore: ^5.0.0
  firebase_storage: ^6.0.0

  # Push Notifications
  firebase_messaging: ^15.0.0

  # State Management
  flutter_riverpod: ^2.5.0

  # Image Handling (optional — for user profile images)
  image_picker: ^1.0.0
```

> **Version alignment**: These Firebase packages must be kept in sync with each other. Run `flutter pub outdated` periodically and update them together. Mixing major versions (e.g. `firebase_auth: ^5` with `firebase_core: ^2`) will cause runtime crashes.

---

## 2. One-Time Firebase CLI Setup

You only need to do this once per development machine.

**Step 1 — Install the Firebase CLI**

Node.js is required. Once installed, run:

```bash
npm install -g firebase-tools
```

**Step 2 — Log into Firebase**

```bash
firebase login
```

**Step 3 — Activate the FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli
```

> **PATH note**: If the `flutterfire` command is not recognized after this step, you need to add the Dart pub cache to your system PATH. The path is typically:
> - macOS/Linux: `$HOME/.pub-cache/bin`
> - Windows: `%LOCALAPPDATA%\Pub\Cache\bin`

---

## 3. Platform Configuration & Initialization

### Step 1: Run FlutterFire Configure

From the root of your Flutter project:

```bash
flutterfire configure
```

This command automatically:
- Registers your app in the Firebase Console
- Generates the `lib/firebase_options.dart` configuration file
- Adds the required native configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

**Re-run this command whenever you:**
- Add a new target platform (e.g. you're adding web support)
- Enable a new Firebase service that requires plugin metadata (Google Sign-In, Crashlytics, Realtime Database)

### Step 2: Initialize Firebase in Dart

Update `lib/main.dart` to initialize Firebase before the app starts. Wrap the root widget with `ProviderScope` so Riverpod can manage provider state globally:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

// Register the FCM background handler before runApp — see Section 6
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Must be registered here, before runApp, so the background isolate can find it
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),
    );
  }
}
```

---

## 4. Application Architecture (Riverpod + Auth)

The architecture follows a clean layered approach:

```
authServiceProvider     → exposes the AuthService instance
        ↓
authStateProvider       → StreamProvider tracking Firebase auth state changes
        ↓
currentUserProvider     → StreamProvider fetching the Firestore user profile
        ↓
UI                      → watches currentUserProvider, rebuilds reactively
```

### Data Layer: User Model

Keep auth credentials out of your model. The model holds only public profile data. `localImageFile` is a transient field used only during upload — it is intentionally excluded from `toMap()` and must never be stored in Firestore.

```dart
import 'dart:io';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String profileImageUrl;
  final File? localImageFile; // Transient — upload only, never persisted

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    this.localImageFile,
  });

  /// Converts to a Firestore-safe map. localImageFile is intentionally excluded.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
    );
  }

  UserModel copyWith({
    String? username,
    String? profileImageUrl,
    File? localImageFile,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      localImageFile: localImageFile ?? this.localImageFile,
    );
  }
}
```

### Service Layer: Authentication Service

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reactive stream of the current Firebase auth user.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Creates the user's Firestore profile document on first registration.
  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }
}
```

> **Note on `async`**: Dart's async syntax is `Future<T> methodName() async { ... }`. The `async` keyword comes *after* the parameter list, not before the return type. This is a common mistake when coming from other languages.

### State Management Layer: Riverpod Providers

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'user_model.dart';

/// Exposes the AuthService singleton to the widget tree.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Tracks real-time Firebase authentication state.
/// Rebuilds any watching widget when the user signs in or out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Fetches the Firestore profile for the currently authenticated user.
/// Returns null if unauthenticated or if the document doesn't exist yet.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(authState.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.exists ? UserModel.fromMap(snapshot.data()!) : null);
});
```

### UI Layer: Auth Gate

Use a simple top-level gate widget to route between auth and main app screens:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Auth error: $e')),
      ),
    );
  }
}
```

---

## 5. Image Handling (Picker + Firebase Storage)

A common pattern: let the user pick an image, upload it to Firebase Storage, then store the download URL in their Firestore document.

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Picks an image from the gallery and uploads it.
  /// Returns the public download URL, or null if cancelled.
  Future<String?> pickAndUploadProfileImage(String uid) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compress before uploading
    );

    if (picked == null) return null;

    final file = File(picked.path);
    final ref = _storage.ref().child('profile_images/$uid.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    // Update the Firestore document with the new URL
    await _db.collection('users').doc(uid).update({'profileImageUrl': url});

    return url;
  }
}
```

---

## 6. Push Notifications (FCM)

### Background Handler

FCM requires a **top-level, non-anonymous function** for background messages. It must be defined at the top level of a Dart file (not inside a class), and it must be registered in `main()` before `runApp()` — not in `initState()` or any widget lifecycle method.

```dart
// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

/// Must be top-level (not inside a class) and annotated for tree-shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main() before this is registered,
  // but if you need Firestore here, call Firebase.initializeApp() again
  // since background isolates have separate memory.
  debugPrint('Background message received: ${message.messageId}');
}
```

### Foreground Notification Setup

Call this function from `initState()` of your **home screen** (the first screen shown after authentication). Do not call it on auth screens.

```dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupNotifications(BuildContext context) async {
  final messaging = FirebaseMessaging.instance;

  // 1. Request system permission (required on iOS; shows dialog on Android 13+)
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );

  if (settings.authorizationStatus != AuthorizationStatus.authorized) {
    debugPrint('Notifications not authorized: ${settings.authorizationStatus}');
    return;
  }

  // 2. Get the FCM registration token for this device.
  //    Store this in Firestore if you want to send targeted notifications.
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');
  // TODO: Save token to Firestore under the user's document if needed

  // 3. Subscribe to topic-based broadcasts
  await messaging.subscribeToTopic('chat');

  // 4. Foreground message handler
  //    Use context.mounted to guard against stale context after awaits
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'New message'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  });

  // 5. App opened from terminated state via notification tap
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('App launched from terminated state via notification');
    // TODO: Navigate to the relevant screen based on message.data
  }

  // 6. App brought to foreground via notification tap (was backgrounded)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('App foregrounded via notification tap');
    // TODO: Navigate to the relevant screen based on message.data
  });
}
```

Then in your home screen:

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Run setup after the first frame so BuildContext is fully attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupNotifications(context);
    });
  }

  // ...
}
```

### Android Manifest

Add inside the `<manifest>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 7. Firestore Security Rules

**This step is critical.** New Firebase projects start in test mode, which allows anyone to read and write all data. Before you ship — or even share a test build — lock down your rules.

A solid baseline for a user-profile app:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read and write their own profile document
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Deny everything else by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Deploy rules from the Firebase Console under **Firestore → Rules**, or via CLI:

```bash
firebase deploy --only firestore:rules
```

---

## 8. Troubleshooting Android Build Errors

If you see errors like `cannot find symbol: FlutterFirebaseStoragePlugin` or similar plugin resolution failures on newer Flutter SDKs, the cause is a compatibility gap between the Android Gradle Plugin (AGP) 9.0+ defaults and some FlutterFire packages.

The fix below works reliably. It pins AGP to the stable `8.x` series and aligns the Kotlin plugin format.

> **Context**: This is a workaround for a real ecosystem timing issue — FlutterFire packages sometimes lag behind AGP major releases. Check the [FlutterFire changelog](https://firebase.flutter.dev/docs/overview) when upgrading Flutter to see if a proper fix has landed.

### Step 1: `android/settings.gradle.kts`

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.2" apply false  // Pinned — AGP 9.x breaks FlutterFire
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

include(":app")
```

### Step 2: `android/gradle.properties`

Add these two lines to prevent AGP 9.0 isolation enforcement:

```properties
android.newDsl=false
android.builtInKotlin=false
```

### Step 3: `android/app/build.gradle.kts`

Use `id("kotlin-android")` (the short-form alias) instead of the fully qualified plugin string, and ensure `kotlinOptions` is inside the `android` block:

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")                      // Use this alias, not "org.jetbrains.kotlin.android"
    id("dev.flutter.flutter-gradle-plugin")   // Must come last
}

android {
    namespace = "com.example.your_app"
    compileSdk = flutter.compileSdkVersion   // Managed by Flutter — do not hardcode

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.your_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

**Also remove** any standalone `kotlin { compilerOptions { ... } }` block outside `android { }` if it exists — having both causes a conflict:

```kotlin
// Remove this if present:
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
```

### Step 4: Clean and rebuild

Always do a full clean after changing Gradle files:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 9. iOS-Specific Setup

FCM on iOS requires additional steps beyond what `flutterfire configure` handles automatically.

### Step 1: Enable Push Notification Capability in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode (not `.xcodeproj`)
2. Select the `Runner` target → **Signing & Capabilities**
3. Click **+ Capability** and add **Push Notifications**
4. Also add **Background Modes** and check **Remote notifications**

### Step 2: Configure APNs in Firebase Console

Firebase needs your Apple Push Notification service (APNs) credentials to relay messages to iOS devices. You have two options:

- **APNs Authentication Key** (recommended — doesn't expire): In the Firebase Console, go to **Project Settings → Cloud Messaging → Apple app configuration** and upload a `.p8` key from your Apple Developer account.
- **APNs Certificate** (legacy — expires annually): Upload a `.p12` certificate instead.

### Step 3: Update `ios/Runner/Info.plist`

Add the following to allow background fetch and remote notification wake:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Step 4: iOS Permission Behavior

Unlike Android, iOS will show a system permission dialog the *first time* `requestPermission()` is called. If the user denies it, you cannot show the dialog again — they must go to Settings manually. Consider showing an explainer screen before calling `requestPermission()` so users understand why they're being asked.

---

## Quick Reference

| Task | Command |
|---|---|
| Re-configure Firebase | `flutterfire configure` |
| Clean build | `flutter clean && flutter pub get` |
| Run on device | `flutter run` |
| Deploy Firestore rules | `firebase deploy --only firestore:rules` |
| Check outdated packages | `flutter pub outdated` |