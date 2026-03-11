import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSub;

  AppAuthProvider() {
    _authSub = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  Future<void> _onAuthStateChanged(User? user) async {
    debugPrint('Auth State Changed: user = ${user?.uid}');
    _firebaseUser = user;
    _errorMessage = null;
    
    if (user != null) {
      try {
        _userModel = await _authService.fetchUserProfile(user.uid);
      } catch (e) {
        debugPrint('Error fetching user profile in listener: $e');
      }
    } else {
      _userModel = null;
    }
    
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      _firebaseUser = _authService.currentUser;
      if (_firebaseUser != null) {
        _userModel = await _authService.fetchUserProfile(_firebaseUser!.uid);
      }
      
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignUp Firebase Error: ${e.code} - ${e.message}');
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      debugPrint('SignUp unexpected error: $e');
      _setError('Sign-up failed: ${e.toString()}');
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
    _clearError();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn Firebase Error: ${e.code} - ${e.message}');
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      debugPrint('SignIn unexpected error: $e');
      _setError('Login failed. Please check your credentials.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    _setLoading(false);
  }

  Future<void> sendVerificationEmail() async {
    try {
      await _authService.sendVerificationEmail();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    }
  }

  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      _firebaseUser = _authService.currentUser;
      if (_firebaseUser != null) {
        _userModel = await _authService.fetchUserProfile(_firebaseUser!.uid);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _authService.signInWithGoogle();
      return credential != null;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (_) {
      _setError('Google sign-in failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email);
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

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. If you don\'t have an account, please sign up.';
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
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
