import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppleSignInService {
  Future<UserCredential?> signInWithApple() async {
  final AuthorizationCredentialAppleID appleIDCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );

  final OAuthCredential credential = OAuthProvider("apple.com").credential(
    idToken: appleIDCredential.identityToken,
    accessToken: appleIDCredential.authorizationCode,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

}
