import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/booking/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _providerNames = {};

  Future<String> _getProviderName(String providerId) async {
    if (_providerNames.containsKey(providerId)) {
      return _providerNames[providerId]!;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(providerId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        String fullName = _extractFullName(data);
        _providerNames[providerId] = fullName;
        return fullName;
      }

      _providerNames[providerId] = providerId;
      return providerId;
    } catch (e) {
      print('Error fetching provider name for ID $providerId: $e');
      _providerNames[providerId] = providerId;
      return providerId;
    }
  }

  String _extractFullName(Map<String, dynamic>? data) {
    if (data == null) return '';
    
    String firstName = data['firstName']?.toString() ?? '';
    String lastName = data['lastName']?.toString() ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else {
      return data['name']?.toString() ?? '';
    }
  }

  Future<List<BookingModel>> fetchAllBookings(String currentBookingId) async {
    final querySnapshot = await _firestore
        .collection('bookingnow')
        .orderBy('timestamp', descending: true)
        .get()
        .timeout(const Duration(seconds: 15));

    List<BookingModel> bookings = [];
    
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      String providerId = data['provider']?.toString() ?? '';
      String providerName = '';
      
      if (providerId.isNotEmpty) {
        providerName = await _getProviderName(providerId);
      }

      Map<String, String> bookingMap = {
        'name': data['name']?.toString() ?? '',
        'time': data['time']?.toString() ?? '',
        'service': data['service']?.toString() ?? '',
        'date': data['date']?.toString() ?? '',
        'location': data['location']?.toString() ?? '',
        'provider': providerName,
        'providerId': providerId,
        'serviceId': data['serviceId']?.toString() ?? '',
        'id': doc.id,
        'isCurrentBooking': doc.id == currentBookingId ? 'true' : 'false',
      };
      
      bookings.add(BookingModel.fromMap(bookingMap));
    }

    bookings.sort((a, b) {
      if (a.isCurrentBooking && !b.isCurrentBooking) {
        return -1;
      } else if (!a.isCurrentBooking && b.isCurrentBooking) {
        return 1;
      }
      return 0;
    });

    return bookings;
  }

  String getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection timed out. Please check your internet connection.';
    } else if (error is FirebaseException) {
      return 'Firebase error: ${error.message ?? 'Unknown Firebase error'}';
    } else {
      return 'Error fetching bookings: $error';
    }
  }

  void clearProviderCache() {
    _providerNames.clear();
  }
}