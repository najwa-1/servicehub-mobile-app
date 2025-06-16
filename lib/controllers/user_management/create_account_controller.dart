import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/profile/user_model.dart';

class CreateAccountController extends ChangeNotifier {
  Future<String?> fetchLocation(TextEditingController controller) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions permanently denied';
      }

      final position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final address =
            '${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}';
        controller.text = address;
      }

      return null;
    } catch (e) {
      return 'Failed to fetch location';
    }
  }

  String? validateInput({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String location,
  }) {
    if (firstName.isEmpty || lastName.isEmpty) return 'Name is required';
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(firstName) || !RegExp(r'^[a-zA-Z]+$').hasMatch(lastName)) {
      return 'Names must only contain letters';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) return 'Invalid email';
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) return 'Phone number must be at least 10 digits';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$').hasMatch(password)) {
      return 'Password too weak';
    }
    if (password != confirmPassword) return 'Passwords do not match';
    if (location.isEmpty) return 'Location is required';

    return null;
  }

  Future<String?> createUser({
    required UserModel userModel,
    required String password,
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: userModel.email, password: password);
      final user = userCredential.user;

      if (user == null) return 'User creation failed';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap(user.uid, position.latitude, position.longitude));

      if (userModel.role == 'Service Provider') {
        await FirebaseFirestore.instance.collection('notifications').add({
          'type': 'provider_signup',
          'providerId': user.uid,
          'providerName': '${userModel.firstName} ${userModel.lastName}',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'unread',
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
