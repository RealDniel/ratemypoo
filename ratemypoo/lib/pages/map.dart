import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {

  Location _LocationController = new Location();

  static const LatLng OSU = LatLng(44.5618, -123.2823);
  LatLng? _currentPosition = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GoogleMap(initialCameraPosition: CameraPosition(target: OSU, zoom: 15 ))
      );
  }

  Future<void> getLocationTracking() async{

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _LocationController.serviceEnabled();
    if(_serviceEnabled){

      _serviceEnabled = await _LocationController.requestService();
    }
    else{
      return;
    }

    _permissionGranted = await _LocationController.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await _LocationController.requestPermission();
      if(_permissionGranted !=PermissionStatus.granted){
        return;
      }
    }


    _LocationController.onLocationChanged.listen((LocationData currentLocation){

      if(currentLocation.latitude != null && currentLocation.longitude != null){

        setState(() {
          _currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print(_currentPosition); 
        });
      }
    });
  }
}