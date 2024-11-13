import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication
import 'package:google_sign_in/google_sign_in.dart'; // For Google sign-in functionality

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instance of GoogleSignIn

  //google sign-in function
  Future<User?> signInWithGoogle() async {
  try {
    //returns the account if the user signs in
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      //returns nothing if the user doesn't sign in
      return null;
    }

    //obtains "access token" from google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    //converts google token into firebase token
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //signs in to firebase using the firebase token
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user; //returns the user signed in

    //gets the user's profile picture
    final String? photoUrl = googleUser.photoUrl;

    //returns the user
    return user;

    } catch (e) {
      //catches any errors
      print('Error during Google Sign-In: $e');
      return null; // Handle errors gracefully
    }
  }

  //sign out method
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut(); // Sign out from Firebase
      print('User signed out');
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }
}

