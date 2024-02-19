import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_map_v2/model/user_location.dart';

class DBController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserLocation>> getUserLocations() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('user_locations').get();
      return querySnapshot.docs
          .map((doc) => UserLocation.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting user locations: $e');
      return [];
    }
  }
}
