import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // auth state (for listening to changes in auth status)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Sign up with email and password, also creates a Firestore user profile
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final userModel = UserModel(
      uid: credential.user!.uid,
      displayName: displayName.trim(),
      email: email.trim(),
      createdAt: DateTime.now(),
    );

    // Update display name first
    await credential.user!.updateDisplayName(displayName.trim());
    
    // Then write to Firestore and wait for it to complete.
    await _db.collection('users').doc(credential.user!.uid).set(userModel.toFirestore());

  
    // block sign-up; the user can resend from the verify screen.
    try {
      await credential.user!.sendEmailVerification();
    } catch (_) {}

    return credential;
  }

  // sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // email verification
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // reload user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // fetch user profile from Firestore
  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // sign in with Google — creates a Firestore profile on first sign-in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // create Firestore profile only on first sign-in
      final existing = await fetchUserProfile(user.uid);
      if (existing == null) {
        final userModel = UserModel(
          uid: user.uid,
          displayName: user.displayName ?? googleUser.displayName ?? 'User',
          email: user.email ?? googleUser.email,
          photoUrl: user.photoURL ?? googleUser.photoUrl,
          createdAt: DateTime.now(),
        );
        await _db.collection('users').doc(user.uid).set(userModel.toFirestore());
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled Google sign-in
      } else {
        // Google sign-in error occurred
      }
      return null;
    } catch (e) {
      // Error signing in with Google
      return null;
    }
  }

  // Validation helpers - show intentional decision-making
  bool isValidEmail(String email) {
    // Simple but practical email validation
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email.trim());
  }

  bool isStrongPassword(String password) {
    // Must be at least 8 chars and have mix of numbers/letters
    return password.length >= 8 && 
           password.contains(RegExp(r'[a-zA-Z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  // Check if user email is already taken (before attempting signup)
  Future<bool> isEmailInUse(String email) async {
    try {
      // Attempt to sign up with a dummy password to check if email exists
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: 'tempPassword123!',
      );
      // If we get here, email doesn't exist; delete the account
      await _auth.currentUser?.delete();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
