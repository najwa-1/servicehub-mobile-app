
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get currentUserId => _auth.currentUser?.uid;
  
  Stream<List<NotificationModel>> getProviderNotifications() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .where('providerId', isEqualTo: currentUserId) 
        .snapshots()
        .map((snapshot) {
          var notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) => 
                notification.providerId == currentUserId &&
                [
                  NotificationType.clientRequest,
                  NotificationType.booking_rejected,

                  NotificationType.bookingConfirmed,
                  NotificationType.bookingCancelled,
                  NotificationType.rating,
                ].contains(notification.type) &&
                notification.notificationFor != 'client'
              )
              .toList();
          
          notifications.sort((a, b) {
            Timestamp? aTime = a.createdAt ?? a.timeTimestamp;
            Timestamp? bTime = b.createdAt ?? b.timeTimestamp;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1; 
            if (bTime == null) return -1; 
            
            return bTime.compareTo(aTime);
          });
          
          return notifications;
        });
  }
  
  Stream<List<NotificationModel>> getClientNotifications() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .where('clientId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          var notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) => 
                notification.clientId == currentUserId &&
                [
                  NotificationType.booking,
                  NotificationType.approval,
                  NotificationType.info,
                  NotificationType.booking_rejected,
                  NotificationType.bookingPendingConfirmation,
                  'bookingCompleted',        
                  'bookingCancelled',      
                ].contains(notification.type) &&
                notification.notificationFor != 'provider'
              )
              .toList();
          
          notifications.sort((a, b) {
            Timestamp? aTime = a.createdAt ?? a.timeTimestamp;
            Timestamp? bTime = b.createdAt ?? b.timeTimestamp;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1; 
            if (bTime == null) return -1; 
            
            return bTime.compareTo(aTime);
          });
          
          return notifications;
        });
  }
  
  Stream<List<NotificationModel>> getProviderNotificationsAlternative() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          var notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) => 
                notification.providerId == currentUserId &&
                [
                  NotificationType.clientRequest,
                  NotificationType.booking_rejected,
                  NotificationType.info,
                  NotificationType.bookingConfirmed,
                  NotificationType.bookingCancelled,
                  NotificationType.rating,
                ].contains(notification.type) &&
                notification.notificationFor != 'client'
              )
              .toList();
              
          notifications.sort((a, b) {
            Timestamp? aTime = a.createdAt ?? a.timeTimestamp;
            Timestamp? bTime = b.createdAt ?? b.timeTimestamp;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            
            return bTime.compareTo(aTime);
          });
          
          return notifications;
        });
  }
  
  Stream<List<NotificationModel>> getClientNotificationsAlternative() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          var notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) => 
                notification.clientId == currentUserId &&
                [
                  NotificationType.booking,
                  NotificationType.approval,
                  NotificationType.info,
                  NotificationType.booking_rejected,
                  NotificationType.bookingPendingConfirmation,
                  'bookingCompleted',
                  'bookingCancelled',
                ].contains(notification.type) &&
                notification.notificationFor != 'provider'
              )
              .toList();
              
          notifications.sort((a, b) {
            Timestamp? aTime = a.createdAt ?? a.timeTimestamp;
            Timestamp? bTime = b.createdAt ?? b.timeTimestamp;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            
            return bTime.compareTo(aTime);
          });
          
          return notifications;
        });
  }
  
  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({'isRead': true});
  }
  
  Future<void> markAllAsRead(List<NotificationModel> notifications) async {
    final batch = _firestore.batch();
    for (var notification in notifications) {
      if (!notification.isRead) { 
        batch.update(
          _firestore.collection('notifications').doc(notification.id),
          {'isRead': true},
        );
      }
    }
    await batch.commit();
  }
  
  Future<void> deleteNotification(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }
  
  Future<void> sendNotificationToClient({
    required String clientId,
    required String message,
    String? title,
    Map<String, dynamic>? bookingData,
    String? type,
    String? bookingId
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    
    await _firestore.collection('notifications').add({
      'clientId': clientId,                  
      'providerId': null,                 
      'title': title ?? 'Booking Update',
      'message': message,
      'isRead': false,
      'time': timestamp,
      'createdAt': timestamp,
      'type': type ?? 'booking',
      'bookingData': bookingData,
      'bookingId': bookingId,
      'notificationFor': 'client',         
    });
  }
  
  Future<void> sendNotificationToProvider({
    required String providerId,
    required String message,
    String? title,
    Map<String, dynamic>? clientData,
    Map<String, dynamic>? bookingData,
    String? type,
    String? bookingId
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    
    await _firestore.collection('notifications').add({
      'clientId': null,                     
      'providerId': providerId,             
      'title': title ?? 'New Request',
      'message': message,
      'isRead': false,
      'time': timestamp,
      'createdAt': timestamp,
      'type': type ?? 'clientRequest',
      'clientData': clientData,
      'bookingData': bookingData,
      'bookingId': bookingId,
      'notificationFor': 'provider',        
    });
  }

  Future<void> sendRatingNotificationToProvider({
    required String providerId,
    required String serviceId,
    required String serviceName,
    required String clientName,
    required double rating,
    required String comment,
  }) async {
    Map<String, dynamic> ratingData = {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'clientName': clientName,
      'rating': rating.toString(),
      'comment': comment,
    };

    String ratingText = '⭐' * rating.toInt();
    if (rating % 1 != 0) ratingText += '⭐';

    final timestamp = FieldValue.serverTimestamp();

    await _firestore.collection('notifications').add({
      'clientId': null,                      
      'providerId': providerId,              
      'title': 'New Rating Received!',
      'message': '$clientName rated your "$serviceName" service $ratingText ($rating/5)',
      'isRead': false,
      'time': timestamp,
      'createdAt': timestamp,
      'type': 'rating',
      'ratingData': ratingData,
      'serviceId': serviceId,
      'notificationFor': 'provider',       
    });
  }
  
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
  }

  Future<void> addToPendingBookings(Map<String, dynamic> bookingData) async {
    await _firestore.collection('pending_bookings').add(bookingData);
  }

  Future<void> addToConfirmedBookings(Map<String, dynamic> bookingData) async {
    await _firestore.collection('bookingnow').add(bookingData);
  }

  Future<void> removePendingBooking(String clientId, String providerId) async {
    final pendingQuery = await _firestore
        .collection('pending_bookings')
        .where('clientId', isEqualTo: clientId)
        .where('provider', isEqualTo: providerId)
        .get();

    for (var doc in pendingQuery.docs) {
      await doc.reference.delete();
    }
  }
  
  Future<void> cleanUpOldNotifications() async {
    final thirtyDaysAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 30))
    );
    
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('createdAt', isLessThan: thirtyDaysAgo)
        .where('isRead', isEqualTo: true)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    if (querySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}