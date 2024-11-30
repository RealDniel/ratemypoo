import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Location _LocationController = Location();

  static const LatLng OSU = LatLng(44.5618, -123.2823);
  LatLng? _currentPosition = null;

  BitmapDescriptor? customIcon;

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
    getLocationTracking();
  }

  Future<void> loadCustomMarker() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/navicon.png', 
    );
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
              initialCameraPosition: const CameraPosition(target: OSU, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: customIcon ?? BitmapDescriptor.defaultMarker,
                  position: _currentPosition!,
                ),
              },
            ),
    );
  }

  Future<void> getLocationTracking() async {
    if (html.window.navigator.geolocation != null) {
      try {
        html.window.navigator.geolocation.getCurrentPosition().then((position) {
          final lat = position.coords?.latitude;
          final lng = position.coords?.longitude;

          if (lat != null && lng != null) {
            setState(() {
              _currentPosition = LatLng(lat.toDouble(), lng.toDouble()); // Ensure values are doubles
              print(_currentPosition);
            });
          } else {
            print('Latitude or Longitude is null');
          }
        });
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Geolocation is not supported in this browser.');
    }
  }
}
