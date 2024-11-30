import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:ratemypoo/pages/review.dart';

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

  @override
  void initState() {
    super.initState();
    loadCustomMarker(); // Load the custom icon
    getLocationTracking();
    _loadReviewMarkers();
  }

  Future<void> loadCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)), // Optionally set the size
      'assets/navicon.png', // Path to your asset
    );
    setState(() {}); // Trigger a rebuild after loading the icon
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
              myLocationButtonEnabled: true,  // Enable location button
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: (LatLng position) {
                _onMapTapped(position);
              },
            ),
    );
  }

  Future<void> _loadReviewMarkers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('reviews').get();

      Set<Marker> newMarkers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(
            title: data['title'],
            snippet: 'Rating: ${data['rating']}',
          ),
          onTap: () {
            _onMarkerTapped(doc.id);
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

  void _onMapTapped(LatLng position) {
  }

  void _onMarkerTapped(String markerId) {
 
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ReviewForm(markerId: MarkerId(markerId)); 
    },
  );
}
}
