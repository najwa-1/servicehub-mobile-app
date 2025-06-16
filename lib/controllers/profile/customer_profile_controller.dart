import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/profile/customer_profile_model.dart';
import '../../views/user_management/login.dart';

class CustomerProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> get userId async => _auth.currentUser?.uid;

  Future<CustomerProfile?> fetchCustomerProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final location = await _resolveLocation(data['location']);

    return CustomerProfile.fromFirestore(data, location);
  }

  Future<String> _resolveLocation(dynamic locationData) async {
    if (locationData is Map) {
      final lat = locationData['latitude'];
      final lng = locationData['longitude'];
      if (lat != null && lng != null) {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        final place = placemarks.first;

        List<String> parts = [];
        if (place.locality?.isNotEmpty ?? false) parts.add(place.locality!);
        else if (place.subLocality?.isNotEmpty ?? false) parts.add(place.subLocality!);
        if (place.administrativeArea?.isNotEmpty ?? false) parts.add(place.administrativeArea!);
        if (place.country?.isNotEmpty ?? false) parts.add(place.country!);

        return parts.join(", ");
      }
    }
    return '';
  }

  Future<void> updateField(String field, String value) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({field: value});
    }
  }

  Future<String?> updateProfileImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final encoded = base64Encode(bytes);
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({'profileImage': encoded});
      }
      return encoded;
    }
    return null;
  }

  Future<void> deleteAccount(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String? email = user.email;
    if (email == null) return;

    final password = await _promptPassword(context);
    if (password == null) return;

    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<String?> _promptPassword(BuildContext context) async {
    String password = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Re-authenticate"),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Enter your password'),
            onChanged: (value) => password = value,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, password), child: const Text("Confirm")),
          ],
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Log Out"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
