import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'user_profile_service.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _profile = UserProfileService(firestore ?? FirebaseFirestore.instance),
        _google = googleSignIn ?? GoogleSignIn(),
        _facebook = facebookAuth ?? FacebookAuth.instance;

  final FirebaseAuth _auth;
  final UserProfileService _profile;
  final GoogleSignIn _google;
  final FacebookAuth _facebook;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // -----------------------
  // Email/Password
  // -----------------------
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (cred.user != null) {
        await _profile.ensureUserDoc(user: cred.user!);
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = cred.user;
      if (user != null) {
        final displayName = '${firstName.trim()} ${lastName.trim()}'.trim();
        await user.updateDisplayName(displayName);
        await user.reload();

        await _profile.ensureUserDoc(
          user: _auth.currentUser!,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phone: phone.trim(),
        );
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  // -----------------------
  // Google
  // -----------------------
  Future<UserCredential> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        throw 'Google sign-in cancelled';
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        await _profile.ensureUserDoc(user: cred.user!);
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // -----------------------
  // Facebook
  // -----------------------
  Future<UserCredential> signInWithFacebook() async {
    try {
      final result = await _facebook.login(permissions: ['email', 'public_profile']);
      if (result.status != LoginStatus.success) {
        throw result.message ?? 'Facebook sign-in cancelled';
      }

      final accessToken = result.accessToken;
      if (accessToken == null) throw 'Facebook access token missing';

      final credential = FacebookAuthProvider.credential(accessToken.tokenString);
      final cred = await _auth.signInWithCredential(credential);

      if (cred.user != null) {
        await _profile.ensureUserDoc(user: cred.user!);
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // -----------------------
  // Apple
  // -----------------------
  Future<UserCredential> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw 'Apple Sign-In works on iOS/macOS (Android not supported)';
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCred = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final cred = await _auth.signInWithCredential(oauthCred);

      // تحديث displayName من fullName إذا متوفر
      final user = cred.user;
      final fullName = appleCredential.givenName == null && appleCredential.familyName == null
          ? null
          : '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();

      if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
        if (fullName != null && fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }
      }

      if (_auth.currentUser != null) {
        await _profile.ensureUserDoc(user: _auth.currentUser!);
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await _google.signOut();
    await _facebook.logOut();
    await _auth.signOut();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'invalid-email':
        return 'Invalid email.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
