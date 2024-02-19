import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocation {
  final String id;
  final String name;
  final GeoPoint coordinates; // Change the data type to GeoPoint

  UserLocation({
    required this.id,
    required this.name,
    required this.coordinates, // Change the parameter and property type
  });

  factory UserLocation.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserLocation(
      id: doc.id,
      name: data['name'],
      coordinates: data['coordinates'], // Access the GeoPoint directly
    );
  }
}
