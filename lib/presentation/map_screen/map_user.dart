import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class MapUser extends StatefulWidget {
  const MapUser({Key? key}) : super(key: key);

  @override
  State<MapUser> createState() => _MapUserState();
}

class _MapUserState extends State<MapUser> {
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};
  String googleApiKey = "AIzaSyCa-Y63qjt3I2XcSItrizLrVXsGulUF7Hg";
  List<LatLng> latLngList = [];
  bool _isPolylinesDrawn = false;
  LatLng? _currentPosition;
  DateTime? _lastUpdateTime;
  double? _speed;
  double? _remainingDistance;
  String? _arrivalTime;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition =
          LatLng(7.2906, 80.6337);
    });
    _subscribeToDestinationUpdates(); // Start listening for destination updates
    _showRouteToDestination(); // Show initial route
  }

  void _subscribeToDestinationUpdates() {
    FirebaseFirestore.instance
        .collection('Bus_locations')
        .doc('track_location')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        GeoPoint destinationGeoPoint = snapshot['coordinates'];
        LatLng destinationLatLng = LatLng(
            destinationGeoPoint.latitude, destinationGeoPoint.longitude);
        _drawRouteToDestination(destinationLatLng);
        _calculateSpeed(destinationLatLng);
        _calculateRemainingDistance(destinationLatLng);
        _calculateArrivalTime();
      }
    });
  }

  void _calculateSpeed(LatLng newLocation) {
    if (_currentPosition != null && _lastUpdateTime != null) {
      double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          newLocation.latitude,
          newLocation.longitude);
      DateTime currentTime = DateTime.now();
      int timeDiffInSeconds =
          currentTime.difference(_lastUpdateTime!).inSeconds;
      double speed = (distance / 1000) / (timeDiffInSeconds / 3600); // Convert to km/h
      setState(() {
        _speed = speed;
      });
    }
    setState(() {
      _currentPosition = newLocation;
      _lastUpdateTime = DateTime.now();
    });
  }

  void _calculateRemainingDistance(LatLng destinationLocation) {
    if (_currentPosition != null) {
      double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude);
      setState(() {
        _remainingDistance = distance / 1000; // Convert to kilometers
      });
    }
  }

  void _calculateArrivalTime() {
    if (_speed != null && _remainingDistance != null) {
      double timeInHours = _remainingDistance! / _speed!;
      DateTime currentTime = DateTime.now();
      DateTime arrivalDateTime = currentTime.add(Duration(hours: timeInHours.toInt()));
      String formattedTime = DateFormat('HH:mm').format(arrivalDateTime); // Format as hours and minutes
      setState(() {
        _arrivalTime = formattedTime;
      });
    }
  }

  void _drawRouteToDestination(LatLng destinationLocation) async {
    // Clear previous polylines
    polylines.clear();

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(point);
      });
    }
    Polyline polyline = Polyline(
      polylineId: PolylineId("route"),
      color: Colors.blue,
      points: polylineCoordinates
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
      width: 5,
    );
    setState(() {
      polylines.add(polyline);
    });
  }

  void _showRouteToDestination() async {
    if (_currentPosition != null) {
      try {
        DocumentSnapshot destinationDoc = await FirebaseFirestore.instance
            .collection('Bus_locations')
            .doc('track_location')
            .get();
        if (destinationDoc.exists) {
          GeoPoint destinationGeoPoint = destinationDoc['coordinates'];
          LatLng destinationLocation = LatLng(
              destinationGeoPoint.latitude, destinationGeoPoint.longitude);
          _drawRouteToDestination(destinationLocation);
        }
      } catch (e) {
        print("Error fetching destination or drawing route: $e");
      }
    }
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition ?? LatLng(0.0, 0.0), // A default fallback location
        zoom: 14,
      ),
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      markers: {}, // Add your markers if needed
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _currentPosition == null ? Center(child: CircularProgressIndicator()) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _speed != null ? 'Speed: ${_speed!.toStringAsFixed(2)} km/h' : 'Speed: N/A',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              _arrivalTime != null ? 'Estimated Arrival Time: $_arrivalTime' : 'Estimated Arrival Time: N/A',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(child: _buildMap()),
          ],
        ),
      ),
    );
  }
}
