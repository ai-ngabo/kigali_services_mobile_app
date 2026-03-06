import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<User?>? _authSub;

  AppAuthProvider() {
    _authSub = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    _errorMessage = null;
    if (user != null) {
      _userModel = await _authService.fetchUserProfile(user.uid);
    } else {
      _userModel = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _authService.sendVerificationEmail();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    }
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
    _firebaseUser = _authService.currentUser;
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}