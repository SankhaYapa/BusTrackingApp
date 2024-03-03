import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/model/user_location.dart';
import 'package:firebase_database/firebase_database.dart';

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
  List<UserLocation> userLocations = [];
  @override
  void initState() {
    super.initState();
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null && user.email == "schoolbus@gmail.com") {
      // Don't run _getCurrentLocation() for the specified email
      _getCurrentLocation();
      // _listenToLocationChanges();
    } else {
      // Run _getCurrentLocation() for other users
      _getCurrentLocation();
    }
  }

  ///Bus Location
  ///
  ///
  ///
  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high, distanceFilter: 10)
        .listen((Position position) {
      _updateLocationToDatabase(position);
      print(position.latitude.toDouble());
      print(position.longitude.toDouble());
    });
  }

  void _updateLocationToDatabase(Position position) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    String currentUserId = "track_location";

    databaseReference.child('Bus_locations').child(currentUserId).set({
      'name': 'BusTracking', // You can add more user details here
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': ServerValue.timestamp, // Use ServerValue.timestamp here
    }).then((_) {
      print("Location updated to Database successfully");
    }).catchError((error) {
      print("Error updating location to Database: $error");
    });
  }

  ///
  ///
  ///
  ///
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
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
        LatLng destinationLatLng =
            LatLng(destinationGeoPoint.latitude, destinationGeoPoint.longitude);
        _drawRouteToDestination(destinationLatLng);
        _drawRouteDirections();

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
      double speed =
          (distance / 1000) / (timeDiffInSeconds / 3600); // Convert to km/h
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
      DateTime arrivalDateTime =
          currentTime.add(Duration(hours: timeInHours.toInt()));
      String formattedTime = DateFormat('HH:mm')
          .format(arrivalDateTime); // Format as hours and minutes
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

  // Widget _buildMap() {
  //   return GoogleMap(
  //     initialCameraPosition: CameraPosition(
  //       target:
  //           _currentPosition ?? LatLng(0.0, 0.0), // A default fallback location
  //       zoom: 14,
  //     ),
  //     onMapCreated: (GoogleMapController controller) {
  //       mapController = controller;
  //     },
  //     markers: {}, // Add your markers if needed
  //     polylines: polylines,
  //     myLocationEnabled: true,
  //     myLocationButtonEnabled: true,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _currentPosition == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   _speed != null
                  //       ? 'Speed: ${_speed!.toStringAsFixed(2)} km/h'
                  //       : 'Speed: N/A',
                  //   style: TextStyle(fontSize: 20),
                  // ),
                  // Text(
                  //   _arrivalTime != null
                  //       ? 'Estimated Arrival Time: $_arrivalTime'
                  //       : 'Estimated Arrival Time: N/A',
                  //   style: TextStyle(fontSize: 20),
                  // ),
                  // SizedBox(height: 20),
                  Expanded(child: _buildMap()),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user_locations')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: Center(child: CircularProgressIndicator()));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No data available'));
                      } else {
                        // Process your snapshot data here
                        return Container(); // Return your desired widget
                      }
                    },
                  ),
                ],
              ),
        bottomNavigationBar: _buildRow(context),
      ),
    );
  }

  Widget _buildRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25.h, right: 18.h, bottom: 31.v),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgImage11,
            height: 36.v,
            width: 41.h,
            margin: EdgeInsets.only(bottom: 4.v),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.h, top: 9.v, bottom: 10.v),
            child: Text(
              _speed != null ? '${_speed!.toStringAsFixed(2)} km/h' : '0 km/h',
              style: theme.textTheme.titleMedium,
            ),
          ),
          CustomImageView(
            imagePath: ImageConstant.imgImage21,
            height: 29.v,
            width: 31.h,
            margin: EdgeInsets.only(left: 29.h, top: 7.v, bottom: 4.v),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.h, top: 9.v, bottom: 10.v),
            child: Text(
              _arrivalTime != null ? '$_arrivalTime' : '0',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('Bus_locations').snapshots(),
      builder: (context, busSnapshot) {
        if (busSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (busSnapshot.hasError) {
          return Center(child: Text('Error: ${busSnapshot.error}'));
        } else if (!busSnapshot.hasData) {
          return Center(child: Text('No bus data available'));
        } else {
          List<LatLng> busLatLngList = busSnapshot.data!.docs
              .map((doc) => LatLng(
                    doc['coordinates'].latitude,
                    doc['coordinates'].longitude,
                  ))
              .toList();

          Set<Marker> busMarkers = busLatLngList.map((latLng) {
            return Marker(
              markerId:
                  MarkerId('bus_marker_${latLng.latitude}_${latLng.longitude}'),
              position: latLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: 'Bus Location'),
            );
          }).toSet();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_locations')
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}'));
              } else if (!userSnapshot.hasData) {
                return Center(child: Text('No user data available'));
              } else {
                userLocations = userSnapshot.data!.docs
                    .map((doc) => UserLocation.fromDocument(doc))
                    .toList();

                List<LatLng> userLatLngList = userLocations.map((location) {
                  return LatLng(
                    location.coordinates.latitude,
                    location.coordinates.longitude,
                  );
                }).toList();

                Set<Marker> userMarkers = userLatLngList.map((latLng) {
                  return Marker(
                    markerId: MarkerId(
                        'user_marker_${latLng.latitude}_${latLng.longitude}'),
                    position: latLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(title: 'User Location'),
                  );
                }).toSet();

                double maxHeight = MediaQuery.of(context).size.height * 0.8;

                // Draw polylines here
                _drawRouteDirections();

                return Container(
                  height: maxHeight,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: busLatLngList.isNotEmpty
                          ? busLatLngList.first
                          : LatLng(0.0, 0.0),
                      zoom: 16,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    markers: {...busMarkers, ...userMarkers},
                    polylines: polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  void _drawRouteDirections() async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> polylineCoordinates = [];

    for (int i = 0; i < userLocations.length - 1; i++) {
      PointLatLng source = PointLatLng(userLocations[i].coordinates.latitude,
          userLocations[i].coordinates.longitude);
      PointLatLng destination = PointLatLng(
          userLocations[i + 1].coordinates.latitude,
          userLocations[i + 1].coordinates.longitude);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        source,
        destination,
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.addAll(result.points);
      }
    }

    Polyline polyline = Polyline(
      polylineId: PolylineId("route"),
      color: Color.fromARGB(255, 247, 0, 222),
      points: polylineCoordinates
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
      width: 6,
    );

    setState(() {
      polylines.add(polyline);
    });
  }

  onTapImgImageTwenty(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.homepageContainerScreen);
  }
}
