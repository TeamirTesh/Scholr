import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scholr/models/user_model.dart';
import 'package:scholr/services/auth_service.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._firestoreService, this._notificationService) {
    _authService.authStateChanges().listen((firebaseUser) {
      _userSub?.cancel();
      _cachedUser = null;
      _loginError = null;
      if (firebaseUser != null) {
        _userSub = _firestoreService.streamUser(firebaseUser.uid).listen((model) {
          _cachedUser = model;
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  StreamSubscription<UserModel?>? _userSub;
  UserModel? _cachedUser;

  /// Latest user document from Firestore, updated live when logged in.
  UserModel? get currentUser => _cachedUser;

  bool isLoading = false;
  String? _loginError;
  String? get loginError => _loginError;

  User? get firebaseUser => _authService.currentUser;
  String? get uid => firebaseUser?.uid;
  bool get isAuthenticated => firebaseUser != null;

  Stream<UserModel?>? get userStream => uid == null ? null : _firestoreService.streamUser(uid!);

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> login(String email, String password) async {
    _loginError = null;
    isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
      await _syncFcm();
    } catch (e, st) {
      log('login failed', error: e, stackTrace: st);
      _loginError = _messageFromAuthError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _messageFromAuthError(Object e) {
    if (e is FirebaseAuthException) {
      return e.message ?? e.code;
    }
    return e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
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
      if (await _firestoreService.isRoomsEmpty()) {
        await _firestoreService.seedRooms();
      }
    } catch (e, st) {
      log('signup failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _loginError = null;
    isLoading = true;
    notifyListeners();
    try {
      final cred = await _authService.signInWithGoogle();
      final user = cred?.user;
      if (user == null) {
        _loginError = 'Sign in was cancelled';
        return;
      }
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
        if (await _firestoreService.isRoomsEmpty()) {
          await _firestoreService.seedRooms();
        }
      }
      await _syncFcm();
    } catch (e, st) {
      log('google sign-in failed', error: e, stackTrace: st);
      _loginError = _messageFromAuthError(e);
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

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final id = uid;
    if (id == null) return;
    await _firestoreService.updateUser(id, data);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
