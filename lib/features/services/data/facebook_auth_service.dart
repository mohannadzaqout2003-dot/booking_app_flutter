import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacebookSignInService {
 Future<UserCredential?> signInWithFacebook() async {
  final LoginResult result = await FacebookAuth.instance.login();

  if (result.status == LoginStatus.success) {
    final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  return null;
}


  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }
}
