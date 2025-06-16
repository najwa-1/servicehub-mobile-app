
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking/client_model.dart';
import '../services/notification_service.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  User? get currentUser => _auth.currentUser;

  Future<List<ClientModel>> loadClients() async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final bookingsSnapshot = await _firestore
          .collection('bookingnow')
          .where('provider', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'confirmed')
          .get();

      final List<ClientModel> clients = [];

      for (var doc in bookingsSnapshot.docs) {
        final bookingData = doc.data();
        bookingData['id'] = doc.id;
        
        final clientId = bookingData['clientId']?.toString();

        if (clientId != null) {
          try {
            final clientDoc = await _firestore
                .collection('users')
                .doc(clientId)
                .get();
                
            if (clientDoc.exists) {
              final clientData = clientDoc.data() ?? {};
              bookingData['email'] = clientData['email'] ?? 'N/A';
              bookingData['phone'] = clientData['phone'] ?? 'N/A';
              bookingData['profileImage'] = clientData['profileImage'];
            }
          } catch (e) {
            print('Error fetching client details: $e');
          }
        }

        final client = ClientModel.fromMap(bookingData, doc.id);
        clients.add(client);
      }

      return clients;
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

 
  Future<void> updateExistingCompletedBookings() async {
    try {
      final completedBookingsSnapshot = await _firestore
          .collection('completedBookings')
          .where('status', isEqualTo: 'completed')
          .get();

      final batch = _firestore.batch();
      
      for (var doc in completedBookingsSnapshot.docs) {
        final data = doc.data();
        if (data['canRate'] == null) {
          batch.update(doc.reference, {'canRate': true});
        }
      }
      
      await batch.commit();
      print('Updated ${completedBookingsSnapshot.docs.length} completed bookings');
    } catch (e) {
      print('Error updating existing completed bookings: $e');
    }
  }
  Future<void> completeBooking(String bookingId) async {
  try {
    final docRef = _firestore.collection('bookingnow').doc(bookingId);
    final snapshot = await docRef.get();
    
    if (snapshot.exists) {
      final data = snapshot.data() ?? {};
      final clientId = data['clientId']?.toString();
      final serviceName = data['service']?.toString() ?? 'Service';
      
      await docRef.update({
        'status': 'completed',
        'canRate': true, 
        'completedAt': FieldValue.serverTimestamp(),
      });
      
      data['completedAt'] = FieldValue.serverTimestamp();
      data['status'] = 'completed';
      data['canRate'] = true; 
      await _firestore.collection('completedBookings').add(data);
      
      await docRef.delete();
      
      if (clientId != null && clientId.isNotEmpty) {
        await _notificationService.sendNotificationToClient(
          clientId: clientId,
          title: 'Service Completed Successfully',
          message: 'Your "$serviceName" booking has been completed. You can now rate us!',
          type: 'success'
        );
      }
    }
  } catch (e) {
    throw Exception('Error completing booking: $e');
  }
}
  Future<void> deleteBooking(String bookingId) async {
    try {
      final docRef = _firestore.collection('bookingnow').doc(bookingId);
      final snapshot = await docRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final clientId = data['clientId']?.toString();
        final serviceName = data['service']?.toString() ?? 'Service';
        
        await docRef.delete();
        
        if (clientId != null && clientId.isNotEmpty) {
          await _notificationService.sendNotificationToClient(
            clientId: clientId,
            title: 'Booking Cancelled',
            message: 'We apologize, but your "$serviceName" booking has been cancelled. We\'re sure you can make another booking anytime!',
            type: 'info'
          );
        }
      }
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }

  List<ClientModel> sortClients(List<ClientModel> clients, String sortColumn, bool sortAscending) {
    final sortedClients = List<ClientModel>.from(clients);
    
    sortedClients.sort((a, b) {
      switch (sortColumn) {
        case 'name':
          final aName = a.name ?? '';
          final bName = b.name ?? '';
          return sortAscending ? aName.compareTo(bName) : bName.compareTo(aName);
        case 'service':
          final aService = a.service ?? '';
          final bService = b.service ?? '';
          return sortAscending ? aService.compareTo(bService) : bService.compareTo(aService);
        case 'date':
          final aDate = a.date ?? '';
          final bDate = b.date ?? '';
          return sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        case 'timestamp':
        default:
          final aTimestamp = a.timestamp;
          final bTimestamp = b.timestamp;
          if (aTimestamp == null || bTimestamp == null) return 0;
          return sortAscending ? aTimestamp.compareTo(bTimestamp) : bTimestamp.compareTo(aTimestamp);
      }
    });
    
    return sortedClients;
  }

  List<ClientModel> filterClients(List<ClientModel> clients, String searchQuery) {
    if (searchQuery.isEmpty) return clients;
    
    return clients.where((client) {
      final name = (client.name ?? '').toLowerCase();
      final service = (client.service ?? '').toLowerCase();
      final location = (client.location ?? '').toLowerCase();
      final date = (client.date ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return name.contains(query) || 
             service.contains(query) || 
             location.contains(query) || 
             date.contains(query);
    }).toList();
  }
}