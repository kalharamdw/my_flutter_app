import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/local_db.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _fs = FirestoreService();
  final _google = GoogleSignIn();

  AuthStatus status = AuthStatus.idle;
  String errorMsg = '';

  User? get user => _auth.currentUser;
  bool get isLoggedIn => user != null;
  String get uid => user?.uid ?? '';
  String get displayName =>
      user?.displayName ?? user?.email?.split('@').first ?? 'there';

  void _setStatus(AuthStatus s, [String msg = '']) {
    status = s;
    errorMsg = msg;
    notifyListeners();
  }

  /// Email/password login
  Future<bool> signInEmail(String email, String pass) async {
    _setStatus(AuthStatus.loading);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _setStatus(AuthStatus.error, _friendlyError(e.code));
      return false;
    }
  }

  /// Email/password sign up
  Future<bool> signUpEmail(String email, String pass, String name) async {
    _setStatus(AuthStatus.loading);
    try {
      final result =
      await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await result.user?.updateDisplayName(name);

      await _fs.saveUserProfile(result.user!.uid, {
        'uid': result.user!.uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _setStatus(AuthStatus.error, _friendlyError(e.code));
      return false;
    }
  }

  /// Google login
  Future<bool> signInGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _setStatus(AuthStatus.idle);
        return false;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Save user if new
      if (result.additionalUserInfo?.isNewUser == true) {
        await _fs.saveUserProfile(result.user!.uid, {
          'uid': result.user!.uid,
          'name': result.user!.displayName ?? '',
          'email': result.user!.email ?? '',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _setStatus(AuthStatus.error, _friendlyError(e.code));
      return false;
    } catch (e) {
      print("Google Sign-In error: $e");
      _setStatus(AuthStatus.error, 'Google sign-in failed');
      return false;
    }
  }

  /// ✅ Guest login (anonymous)
  Future<bool> signInGuest() async {
    _setStatus(AuthStatus.loading);
    try {
      final result = await _auth.signInAnonymously();

      // Optional: save minimal guest profile
      await _fs.saveUserProfile(result.user!.uid, {
        'uid': result.user!.uid,
        'name': 'Guest',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, 'Anonymous sign-in failed');
      return false;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    _setStatus(AuthStatus.loading);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setStatus(AuthStatus.error, 'Reset email sent! Check your inbox.');
    } on FirebaseAuthException catch (e) {
      _setStatus(AuthStatus.error, _friendlyError(e.code));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
    _setStatus(AuthStatus.idle);
  }

  void resetStatus() => _setStatus(AuthStatus.idle);

  /// Friendly error messages
  String _friendlyError(String code) => switch (code) {
    'user-not-found' => 'No account found with this email.',
    'wrong-password' => 'Incorrect password.',
    'email-already-in-use' => 'An account with this email already exists.',
    'weak-password' => 'Password must be at least 6 characters.',
    'invalid-email' => 'Please enter a valid email address.',
    'network-request-failed' => 'No internet connection.',
    _ => 'Something went wrong. Please try again.',
  };
}