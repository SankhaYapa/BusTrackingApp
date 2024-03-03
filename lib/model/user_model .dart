import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? uid;
  final String? email;
  final String? address;
  final String? contact1;
  final String? contact2;
  final String? firstName;
  final String? lastName;
  final String? school;

  UserModel({
    this.uid,
    this.email,
    this.address,
    this.contact1,
    this.contact2,
    this.firstName,
    this.lastName,
    this.school,
  });

  factory UserModel.fromFirebaseUser(User user, Map<String, dynamic> userData) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      address: userData['Address'],
      contact1: userData['contact1'],
      contact2: userData['contact2'],
      firstName: userData['firstname'],
      lastName: userData['lastname'],
      school: userData['school'],
    );
  }
}
