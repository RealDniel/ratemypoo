import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateWidget extends StatefulWidget {
  const CreateWidget({super.key});

  @override
  State<CreateWidget> createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  GoogleMapController? _mapController;
  LatLng? _selectedLocation; // Variable to hold selected location

  String _selectedBathroomType = 'Male';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rate your experience by tapping on the stars and entering into the boxes:',
                style: TextStyle(fontSize: 18),
              ),
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
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Location'),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(height: 20),

              const Text('Select Bathroom Type:', style: TextStyle(fontSize: 18)),
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Mens'),
                    value: 'Male',
                    groupValue: _selectedBathroomType,
                    onChanged: (value) {
                      setState(() {
                        _selectedBathroomType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Womens'),
                    value: 'Female',
                    groupValue: _selectedBathroomType,
                    onChanged: (value) {
                      setState(() {
                        _selectedBathroomType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Single-User'),
                    value: 'Single',
                    groupValue: _selectedBathroomType,
                    onChanged: (value) {
                      setState(() {
                        _selectedBathroomType = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Select Location on Map:', style: TextStyle(fontSize: 18)),
              SizedBox(
                height: 300,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(44.5618, -123.2823),
                    zoom: 15,
                  ),
                  onTap: _onMapTapped, // Ensure onTap is calling _onMapTapped
                  markers: _selectedLocation == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('selectedLocation'),
                            position: _selectedLocation!,
                            infoWindow: const InfoWindow(title: 'Selected Location'),
                          ),
                        },
                ),
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
      ),
    );
  }

  // This method will update _selectedLocation whenever the user taps on the map
  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
  }

  // Submit the review to Firestore
  Future<void> _submitReview() async {
    String title = _titleController.text.trim();
    String locationName = _locationController.text.trim();
    String reviewText = _reviewController.text.trim();

    if (title.isEmpty || locationName.isEmpty || reviewText.isEmpty || _rating == 0.0 || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill out your review completely'),
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
      // Generate a unique ID for the review (markerId)
      DocumentReference newReviewRef = FirebaseFirestore.instance.collection('reviews').doc();

      // Add review to Firestore
      await newReviewRef.set({
        'userId': user.uid,
        'userName': user.displayName,
        'userPhotoURL': user.photoURL,
        'title': title,
        'location': locationName,
        'description': reviewText,
        'rating': _rating,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'bathroom': _selectedBathroomType,
        "markerId": newReviewRef.id, // Use the document ID as markerId
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Review submitted successfully'),
      ));

      // Clear the previous text from the inputs
      _titleController.clear();
      _locationController.clear();
      _reviewController.clear();
      setState(() {
        _rating = 0.0;
        _selectedLocation = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting review: $e'),
      ));
    }
  }
}
