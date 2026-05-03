import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scholr/models/user_model.dart';
import 'package:scholr/services/auth_service.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._firestoreService, this._notificationService) {
    _authService.authStateChanges().listen((_) => notifyListeners());
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  bool isLoading = false;

  User? get firebaseUser => _authService.currentUser;
  String? get uid => firebaseUser?.uid;
  bool get isAuthenticated => firebaseUser != null;

  Stream<UserModel?>? get userStream => uid == null ? null : _firestoreService.streamUser(uid!);

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
      await _syncFcm();
    } catch (e, st) {
      log('login failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({required String name, required String email, required String password}) async {
    isLoading = true;
    notifyListeners();
    try {
      final cred = await _authService.signUpWithEmail(email, password);
      final userId = cred.user!.uid;
      final token = await _notificationService.getToken() ?? '';
      await _firestoreService.createUser(
        UserModel(
          id: userId,
          name: name,
          email: email,
          profilePicUrl: '',
          courses: const ['General Studies'],
          fcmToken: token,
          notificationsEnabled: true,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e, st) {
      log('signup failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();
    try {
      final cred = await _authService.signInWithGoogle();
      final user = cred?.user;
      if (user == null) return;
      final existing = await _firestoreService.getUser(user.uid);
      if (existing == null) {
        final token = await _notificationService.getToken() ?? '';
        await _firestoreService.createUser(
          UserModel(
            id: user.uid,
            name: user.displayName ?? 'Student',
            email: user.email ?? '',
            profilePicUrl: user.photoURL ?? '',
            courses: const ['General Studies'],
            fcmToken: token,
            notificationsEnabled: true,
            createdAt: DateTime.now(),
          ),
        );
      }
      await _syncFcm();
    } catch (e, st) {
      log('google sign-in failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncFcm() async {
    final id = uid;
    if (id == null) return;
    final token = await _notificationService.getToken();
    if (token != null) {
      await _firestoreService.updateUser(id, {'fcmToken': token});
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
