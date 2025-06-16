
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking/booking_confirmation_model.dart';

class BookingConfirmationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final Map<String, String> _providerNamesCache = {};

  Future<String> saveBooking(BookingConfirmationModel booking) async {
    try {
      print('Saving booking to Firebase...');
      print('Provider ID: ${booking.provider}');
      print('Provider Name: ${booking.providerName}');
      
      final currentUser = _auth.currentUser;
      
      final bookingData = booking.toMap();
      bookingData['clientId'] = currentUser?.uid ?? '';
      bookingData['timestamp'] = FieldValue.serverTimestamp();
      
      final docRef = await _firestore
          .collection('bookingnow')
          .add(bookingData);
      
      print('Booking saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving booking to Firebase: $e');
      throw Exception('Failed to save booking: $e');
    }
  }

  Future<String> getProviderName(String providerId) async {
    if (providerId.isEmpty) {
      print('Provider ID is empty');
      return 'Unknown Provider';
    }

    print('Getting provider name for ID: $providerId');
    
    if (_providerNamesCache.containsKey(providerId)) {
      print('Found in cache: ${_providerNamesCache[providerId]}');
      return _providerNamesCache[providerId]!;
    }

    try {
      print('Fetching from Firestore...');
      final userDoc = await _firestore
          .collection('users')
          .doc(providerId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        print('User document data: $data');
        
        final user = UserModel.fromMap(data ?? {}, providerId);
        final fullName = user.fullName;
        
        print('Extracted full name: $fullName');
        
        _providerNamesCache[providerId] = fullName.isNotEmpty ? fullName : providerId;
        return _providerNamesCache[providerId]!;
      } else {
        print('User document does not exist for ID: $providerId');
        _providerNamesCache[providerId] = providerId;
        return providerId;
      }
    } catch (e) {
      print('Error fetching provider name for ID $providerId: $e');
      _providerNamesCache[providerId] = providerId;
      return providerId;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<BookingConfirmationModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection('bookingnow')
          .doc(bookingId)
          .get();

      if (doc.exists) {
        return BookingConfirmationModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching booking: $e');
      throw Exception('Failed to fetch booking: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection('bookingnow')
          .doc(bookingId)
          .update({'status': status});
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }

  static void clearCache() {
    _providerNamesCache.clear();
  }
}