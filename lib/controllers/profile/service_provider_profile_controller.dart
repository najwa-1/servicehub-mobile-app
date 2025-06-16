import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/profile/user_profile_model.dart';

class ServiceProviderProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfile?> loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null) {
          String firstName = data['firstName'] ?? '';
          String lastName = data['lastName'] ?? '';
          String phoneNumber = data['phone'] ?? '';
          Uint8List? imageBytes;

          String location = '';
          final locationData = data['location'];
          if (locationData != null && locationData is Map) {
            final latitude = locationData['latitude'];
            final longitude = locationData['longitude'];
            if (latitude != null && longitude != null) {
              final placemarks = await placemarkFromCoordinates(latitude, longitude);
              final place = placemarks.first;
              List<String> parts = [];

              if (place.locality != null && place.locality!.isNotEmpty) {
                parts.add(place.locality!);
              } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
                parts.add(place.subLocality!);
              }

              if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
                parts.add(place.administrativeArea!);
              }

              if (place.country != null && place.country!.isNotEmpty) {
                parts.add(place.country!);
              }

              location = parts.join(", ");
            }
          }

          final imageData = data['profileImage'];
          if (imageData != null && imageData.isNotEmpty) {
            imageBytes = base64Decode(imageData);
          }

          return UserProfile(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            location: location,
            profileImage: imageBytes,
          );
        }
      }
    } catch (e) {
      print("Error loading user profile: $e");
    }

    return null;
  }

  Future<void> updateProfileField(String field, String value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({field: value});
    }
  }

  Future<void> updateProfileImage(Uint8List imageBytes) async {
    final user = _auth.currentUser;
    if (user != null) {
      final base64String = base64Encode(imageBytes);
      await _firestore.collection('users').doc(user.uid).update({
        'profileImage': base64String,
      });
    }
  }

  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
