import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:road_map_v2/core/app_export.dart';
import 'package:road_map_v2/model/user_location.dart';
import 'package:road_map_v2/widgets/app_bar/appbar_leading_image.dart';
import 'package:road_map_v2/widgets/app_bar/appbar_title.dart';
import 'package:road_map_v2/widgets/app_bar/custom_app_bar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late Set<Polyline> polylines = {};
  String googleApiKey = "AIzaSyCa-Y63qjt3I2XcSItrizLrVXsGulUF7Hg";
  List<UserLocation> userLocations = [];
  bool _isPolylinesDrawn = false;

  late LatLng _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _listenToLocationChanges(); // Call this method in initState to start listening
  }

  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high, distanceFilter: 10)
        .listen((Position position) {
      _updateLocationToFirestore(position);
      print(position.latitude.toDouble());
      print(position.longitude.toDouble());
    });
  }

  void _updateLocationToFirestore(Position position) async {
    // Assuming you have a 'users' collection and a document ID for the current user
    // You might want to replace 'currentUserId' with your actual user ID management logic
    String currentUserId = "track_location";

    FirebaseFirestore.instance
        .collection('Bus_locations')
        .doc(currentUserId)
        .set({
      'name': 'BusTracking', // You can add more user details here
      'coordinates': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(), // Adds a server-side timestamp
    }, SetOptions(merge: true)).then((_) {
      print("Location updated to Firestore successfully");
    }).catchError((error) {
      print("Error updating location to Firestore: $error");
    });
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: _buildMap(),
        ),
        bottomNavigationBar: _buildRow(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 87.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgImage7,
        margin: EdgeInsets.symmetric(vertical: 7.v),
      ),
      centerTitle: true,
      title: AppbarTitle(text: "Track "),
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
              "50mph",
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
              "15 minutes (7km)",
              style: theme.textTheme.titleMedium,
            ),
          ),
          CustomImageView(
            imagePath: ImageConstant.imgImage16,
            height: 34.v,
            width: 32.h,
            margin: EdgeInsets.only(left: 29.h, top: 6.v),
            onTap: () {
              onTapImgImageTwenty(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('user_locations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        } else {
          userLocations = snapshot.data!.docs
              .map((doc) => UserLocation.fromDocument(doc))
              .toList();

          if (userLocations.isNotEmpty && !_isPolylinesDrawn) {
            _drawRouteDirections();
            _isPolylinesDrawn = true;
          }

          List<LatLng> latLngList = userLocations.map((location) {
            return LatLng(
              location.coordinates.latitude,
              location.coordinates.longitude,
            );
          }).toList();

          Set<Marker> markers = userLocations.map((location) {
            return Marker(
              markerId: MarkerId(location.id),
              position: LatLng(location.coordinates.latitude,
                  location.coordinates.longitude),
              infoWindow: InfoWindow(title: location.name),
            );
          }).toSet();

          double maxHeight = MediaQuery.of(context).size.height * 0.8;

          return Container(
            height: maxHeight,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: latLngList.first,
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: markers,
              polylines: polylines,
              myLocationEnabled: true, // Enable current location button
              myLocationButtonEnabled: true, // Enable current location feature
            ),
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
        result.points.forEach((point) {
          polylineCoordinates.add(point);
        });
      }
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

  onTapImgImageTwenty(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.homepageContainerScreen);
  }
}
