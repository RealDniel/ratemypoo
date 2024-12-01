import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Add favorite = FavoriteService.addFavorite(markerId)
  Future<void> addFavorite(String markerId) async {
    final userID = _auth.currentUser?.uid;

    if (userID != null) {
      final userDoc = _firestore.collection('users').doc(userID);

      await userDoc.update({
        'favorites': FieldValue.arrayUnion([markerId]),
      });
    }
  }

  //Remove favorite = FavoriteService.removeFavorite(markerId)
  Future<void> removeFavorite(String markerId) async {
    final userID = _auth.currentUser?.uid;

    if (userID != null) {
      final userDoc = _firestore.collection('users').doc(userID);

      await userDoc.update({
        'favorites': FieldValue.arrayRemove([markerId]),
      });
    }
  }

  //Get favorite list to display on favorite page FavoriteService.getFavorites()
  Future<List<String>> getFavorites() async {
    final userID = _auth.currentUser?.uid;

    //If there is a user, return a list of favorited markerId's
    if (userID != null) {
      final userDoc = await _firestore.collection('users').doc(userID).get();
      final favorites = userDoc.data()?['favorites'] as List<dynamic>?;

      return favorites?.cast<String>() ?? [];
    }

    //No user returns nothing
    return [];
  }
}