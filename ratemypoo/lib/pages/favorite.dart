import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favoriteService = FavoriteService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: _favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data!.isEmpty){
            return const Center(child: Text("You have not added any favorites yet..."));
          } else if (snapshot.hasData){
            final favorites = snapshot.data!;

            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final markerId = favorites[index];

              //Get info about favorite markers
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('reviews').doc(markerId).get(),
                  builder: (context, markerSnapshot) {
                    if (markerSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        title: Text("Loading marker details..."),
                      );
                    } else if (markerSnapshot.hasError || !markerSnapshot.hasData || !markerSnapshot.data!.exists) {
                      return ListTile(
                        title: Text("Details for $markerId not found"),
                      );
                    } else {
                      // Extract data from the Firestore document
                      final markerData = markerSnapshot.data!.data() as Map<String, dynamic>;
                      final location = markerData['location'] ?? 'Unknown';
                      final rating = markerData['rating'] ?? 'No rating';
                      final bathroom = markerData['bathroom'] ?? 'Unknown';


                      //Stuff to display
                      return ListTile(
                        title: Text("$location", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                          children: [
                            Text("Rating: $rating"),

                            Text("Bathroom Type: $bathroom")
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _favoriteService.removeFavorite(markerId);
                            //refresh page after removing a favorite
                            setState(() {});
                          },
                        ),
                      );
                    }
                  }
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}