import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication
import 'package:google_sign_in/google_sign_in.dart'; // For Google sign-in functionality
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instance of GoogleSignIn
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //Instance of firestore

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

    if (user != null) {
        await _createUserDocument(user); // Call the helper method to create the user document
      }

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

  Future<void> _createUserDocument(User user) async {
    final userDocRef = _firestore.collection('users').doc(user.uid); // Reference to the user's document

    // Check if the document already exists
    final docSnapshot = await userDocRef.get();
    if (!docSnapshot.exists) {
      // If the document doesn't exist, create it with default data
      await userDocRef.set({
        'email': user.email, // Store the user's email
        'displayName': user.displayName, // Store the user's display name
        'photoUrl': user.photoURL, // Store the user's profile picture URL
        'favorites': [], // Initialize an empty list for the user's favorites
        'createdAt': FieldValue.serverTimestamp(), // Store the timestamp of when the document was created
      });
      print('User document created for ${user.uid}');
    } else {
      print('User document already exists for ${user.uid}');
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

