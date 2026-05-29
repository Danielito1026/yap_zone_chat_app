import 'package:firebase_auth/firebase_auth.dart';
import 'package:yap_zone/routes/router.dart';
import 'package:yap_zone/services/navigation_service.dart';

class AuthService {
  final NavigationService _nav;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService(this._nav);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<({UserCredential? credential, String? error})> signIn(
    String email,
    String password,
  ) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (credential: cred, error: null);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: $e');
      return (credential: null, error: getAuthErrorMessage(e));
    } catch (e) {
      print('Error signing in: $e');
      return (credential: null, error: e.toString());
    }
  }

  Future<({UserCredential? credential, String? error})> signUp(
    String email,
    String username,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      return (credential: userCredential, error: null);
    } catch (e) {
      // print('Error signing up: $e');
      return (credential: null, error: e.toString());
    }
  }

  String getAuthErrorMessage(Exception error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'user-token-expired':
          return 'Session expired. Please sign in again.';
        case 'network-request-failed':
          return 'Check your internet connection.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'operation-not-allowed':
          return 'Email/Password sign-in is not enabled.';
        default:
          return error.message ?? 'An error occurred.';
      }
    } else {
      return 'An unknown error occurred.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _nav.navigateToRoute(AppRoutes.signIn);
  }
}
