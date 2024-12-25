import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    // On the web, this triggers the Google OAuth popup
    final googleProvider = GoogleAuthProvider();
    return await _firebaseAuth.signInWithPopup(googleProvider);
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
