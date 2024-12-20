import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:ratemypoo/pages/review.dart';
import 'package:ratemypoo/services/favorite_service.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Location _LocationController = Location();
  static const LatLng OSU = LatLng(44.5618, -123.2823);
  LatLng? _currentPosition = null;
  BitmapDescriptor? customIcon; // Variable to store the custom icon
  final Set<Marker> _markers = {}; // Set to hold all markers
  GoogleMapController? _mapController;
  String? _mapStyle; // Variable to store the custom map style

  @override
  void initState() {
    super.initState();
    loadCustomMarker(); // Load the custom icon
    getLocationTracking();
    _loadReviewMarkers(); // Load markers with reviews
    _loadMapStyle(); // Load the map style
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await DefaultAssetBundle.of(context).loadString('assets/custommap.json');
    } catch (e) {
      print('Error loading map style: $e');
    }
  }

  Future<void> loadCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)), // Size of the Marker
      'assets/navicon.png', // Path to your asset
    );
    setState(() {});
  }

  Future<void> getLocationTracking() async {
    if (await _LocationController.serviceEnabled()) {
      try {
        final locData = await _LocationController.getLocation();
        setState(() {
          _currentPosition = LatLng(locData.latitude!, locData.longitude!);
          // Add current location marker
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentPosition!,
              icon: customIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: const InfoWindow(title: 'Current Location'),
            ),
          );
        });
      } catch (e) {
        print('Error fetching location: $e');
      }
    } else {
      print('Location services are not enabled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
              initialCameraPosition: const CameraPosition(target: OSU, zoom: 15),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true, // Enable location button
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_mapStyle != null) {
                  controller.setMapStyle(_mapStyle);
                }
              },
              onTap: (LatLng position) {
                _onMapTapped(position);
              },
            ),
    );
  }

  Future<void> _loadReviewMarkers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('reviews').get();

      Set<Marker> newMarkers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['location'],
          ),
          onTap: () {
            _onMarkerTapped(doc.id, LatLng(data['latitude'], data['longitude'])); // Pass markerId and location
          },
        );
      }).toSet();

      setState(() {
        _markers.addAll(newMarkers); 
      });
    } catch (e) {
      print('Error loading review markers: $e');
    }
  }

  
  void _onMarkerTapped(String markerId, LatLng markerLocation) async {
    try {
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('markerId', isEqualTo: markerId)
          .get();

      double totalRating = 0;
      int reviewCount = reviewSnapshot.docs.length;
      List<Map<String, dynamic>> reviews = [];

      if (reviewCount > 0) {
        for (var doc in reviewSnapshot.docs) {
          Map<String, dynamic> review = doc.data() as Map<String, dynamic>;
          reviews.add(review);
          totalRating += review['rating'].toDouble();
        }
      }

      double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the average rating
                Text(
                  'Average Rating: ${averageRating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                //I WANT TO ADD FAVORITE BUTTON HERE
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FavoriteService().addFavorite(markerId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to favorites!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add to favorites: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('Add to Favorites'),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var review = reviews[index];
                      return ListTile(
                        title: Text(review['title'] ?? 'No title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: ${review['userName']}'),
                            Text('Rating: ${review['rating']}'),
                            Text(review['description'] ?? 'No description'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewForm(
                          markerId: MarkerId(markerId),
                          markerLocation: markerLocation,
                        ),
                      ),
                    );
                  },
                  child: const Text('Add a Review'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching reviews: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  void _onMapTapped(LatLng position) {
    print("Tapped on map at: $position");
  }
}
