import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobile_service_hub/models/booking_form_model.dart';


class BookingFormService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    try {
      final profileDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (profileDoc.exists) {
        return profileDoc.data();
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
    return null;
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      } else {
        return 'Location not found';
      }
    } catch (e) {
      print('Geocoding error: $e');
      return 'Error retrieving location';
    }
  }

  Future<String> parseLocationFromProfile(Map<String, dynamic> profileData) async {
    final locationData = profileData['location'];
    
    if (locationData != null && locationData is Map<String, dynamic>) {
      final lat = locationData['latitude'];
      final lng = locationData['longitude'];
      if (lat != null && lng != null) {
        return await getAddressFromCoordinates(lat, lng);
      }
    }
    return '';
  }

  String parseNameFromProfile(Map<String, dynamic> profileData) {
    final firstName = profileData['firstName'] ?? '';
    final lastName = profileData['lastName'] ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return '';
  }

  String parsePhoneFromProfile(Map<String, dynamic> profileData) {
    return profileData['phone'] ?? '';
  }

  Future<String> submitBooking(BookingFormModel booking) async {
    final user = getCurrentUser();
    if (user == null) {
      throw Exception('You must be logged in to book a service.');
    }

    if (!booking.isValid()) {
      throw Exception('Please fill all fields');
    }

    if (booking.bookingDateTime == null) {
      throw Exception('Invalid date or time');
    }

    try {
      final bookingRef = await _firestore
          .collection('bookings')
          .add(booking.toFirestore());

      await _firestore
          .collection('notifications')
          .add(booking.toNotificationData(bookingRef.id));

      return bookingRef.id;
    } catch (e) {
      print("Error creating booking: $e");
      throw Exception('Booking failed. Please try again');
    }
  }

  DateTime? parseSelectedDateTime(String dateText, String timeText) {
    try {
      final parts = dateText.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final timeOfDay = _parseTimeOfDay(timeText);
      if (timeOfDay == null) return null;

      return DateTime(year, month, day, timeOfDay.hour, timeOfDay.minute);
    } catch (e) {
      return null;
    }
  }

  CustomTimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final format = timeString.toLowerCase().trim();
      final isPm = format.contains('pm');
      final cleanStr = format.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = cleanStr.split(':');
      if (parts.length != 2) return null;
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      return CustomTimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }
}

class CustomTimeOfDay {
  final int hour;
  final int minute;

  CustomTimeOfDay({required this.hour, required this.minute});
}