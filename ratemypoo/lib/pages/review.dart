import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReviewForm extends StatefulWidget {
  final MarkerId markerId;
  final LatLng markerLocation; // Pass location (latitude, longitude) along with markerId

  const ReviewForm({super.key, required this.markerId, required this.markerLocation});

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  double _rating = 0.0;
  String _selectedBathroomType = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate your experience by tapping on the stars:', style: TextStyle(fontSize: 18)),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 0,
              maxRating: 5,
              itemSize: 35.0,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill out all fields and rate your experience.'),
      ));
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You need to be signed in to submit a review'),
      ));
      return;
    }

    try {
      // Add the review to Firestore with the associated markerId and location
      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': user.uid,
        'userName': user.displayName,
        'title': title,
        'description': description,
        'rating': _rating,
        'latitude': widget.markerLocation.latitude,  // Use the actual latitude of the marker
        'longitude': widget.markerLocation.longitude, // Use the actual longitude of the marker
        'markerId': widget.markerId.value,  // Store the markerId for reference
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Review submitted successfully'),
      ));

      Navigator.pop(context); // Close the review form screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting review: $e'),
      ));
    }
  }
}
