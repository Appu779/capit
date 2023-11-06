import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  bool isUserLoggedIn() {
  // Implement your logic here to check if the user is logged in
  // You can use FirebaseAuth to check the authentication state
  final currentUser = FirebaseAuth.instance.currentUser;
  return currentUser != null;
}

bool isCurrentUser(String userId) {
  // Implement your logic here to check if the current user matches the provided userId
  // You can use FirebaseAuth to get the current user and compare the userId
  final currentUser = FirebaseAuth.instance.currentUser;
  return currentUser != null && currentUser.uid == userId;
}

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        await _auth.signInWithCredential(authCredential);
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
      rethrow;
    }
  }

  signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

}
