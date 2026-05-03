import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e, st) {
      log('signInWithEmail failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e, st) {
      log('signUpWithEmail failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final auth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      return await _auth.signInWithCredential(credential);
    } catch (e, st) {
      log('signInWithGoogle failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
    } catch (e, st) {
      log('signOut failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
