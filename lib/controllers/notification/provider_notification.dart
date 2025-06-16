import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_service_hub/views/booking/client_view.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../views/rating/view_ratings_page.dart';

class ProviderNotificationsController {
  final NotificationService _notificationService = NotificationService();
  
  Future<void> onAccept(BuildContext context, NotificationModel notification, Function showLoadingDialog, Function showWaitingForConfirmationPopup, Function showErrorSnackBar) async {
    if (notification.bookingId == null || notification.clientData == null) return;

    showLoadingDialog('Processing request...');

    try {
      await _notificationService.updateBookingStatus(notification.bookingId!, 'pending_confirmation');
      await _notificationService.markAsRead(notification.id);

      final client = notification.clientData!;
      final currentUserId = _notificationService.currentUserId ?? '';
      
      await _notificationService.addToPendingBookings({
        'name': client['name'] ?? '',
        'service': client['service'] ?? '',
        'provider': currentUserId,
        'location': client['location'] ?? '',
        'date': client['date'] ?? '',
        'time': client['time'] ?? '',
        'serviceId': client['serviceId'] ?? '',
        'clientId': notification.clientId ?? '',
        'bookingId': notification.bookingId,
        'status': 'pending_confirmation',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Map<String, dynamic> bookingDataForNotification = Map<String, dynamic>.from(client);
      bookingDataForNotification['provider'] = currentUserId;
      bookingDataForNotification['providerID'] = currentUserId;
      bookingDataForNotification['status'] = 'pending_confirmation';
      
      print('Sending notification with booking data: $bookingDataForNotification');

      final String clientId = notification.clientId ?? '';
      if (clientId.isNotEmpty) {
        await _notificationService.sendNotificationToClient(
          clientId: clientId,
          title: 'Booking Request Accepted',
          message: 'Your booking request has been accepted. Please confirm to finalize.',
          bookingData: bookingDataForNotification,
          type: 'booking_pending_confirmation'
        );
      }

      Navigator.of(context).pop();
      
      showWaitingForConfirmationPopup();
      
    } catch (e) {
      Navigator.of(context).pop();
      
      showErrorSnackBar('Failed to process booking: $e');
    }
  }

  Future<void> onReject(BuildContext context, NotificationModel notification, Function showLoadingDialog, Function showErrorSnackBar, Function showSuccessSnackBar) async {
    if (notification.bookingId == null || notification.clientData == null) return;
    
    showLoadingDialog('Rejecting request...');
    
    try {
      await _notificationService.updateBookingStatus(notification.bookingId!, 'rejected');
      await _notificationService.markAsRead(notification.id);
      
      final String clientId = notification.clientId ?? '';
      if (clientId.isNotEmpty) {
        Map<String, dynamic> bookingDataForNotification = Map<String, dynamic>.from(notification.clientData!);
        bookingDataForNotification['provider'] = _notificationService.currentUserId ?? '';
        bookingDataForNotification['providerID'] = _notificationService.currentUserId ?? '';
        
        await _notificationService.sendNotificationToClient(
          clientId: clientId,
          title: 'Booking Request Rejected',
          message: 'Your booking request has been rejected',
          bookingData: bookingDataForNotification,
          type: 'booking_rejected'
        );
      }
      
      Navigator.of(context).pop();
      
      showSuccessSnackBar('Booking request rejected successfully');
      
    } catch (e) {
      Navigator.of(context).pop();
      
      showErrorSnackBar('Failed to reject booking: $e');
    }
  }

  Stream<List<NotificationModel>> getProviderNotifications() {
    return _notificationService.getProviderNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  Future<void> markAllAsRead(List<NotificationModel> notifications) async {
    await _notificationService.markAllAsRead(notifications);
  }

  Future<void> deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
  }

  void handleNotificationTap(BuildContext context, NotificationModel notification, Function showClientRequestDetailsPopup, Function showRatingDetailsPopup, Function showSuccessSnackBar, Function showErrorSnackBar) async {
    await markAsRead(notification.id);

    if (notification.type == NotificationType.clientRequest && notification.clientData != null) {
      showClientRequestDetailsPopup(context, notification);
    }
    else if (notification.type == NotificationType.rating && notification.ratingData != null) {
      showRatingDetailsPopup(context, notification);
    }
    else if (notification.type == NotificationType.bookingConfirmed) {
      showSuccessSnackBar('Booking confirmed! Navigating to client table...');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnhancedProviderClientsTableView()),
      );
    }
    else if (notification.type == NotificationType.bookingCancelled) {
      showErrorSnackBar('Booking was cancelled by customer');
    }
  }

  void navigateToViewRatings(BuildContext context, NotificationModel notification) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewRatingsPage(
          service: {
            'id': notification.ratingData?['serviceId'] ?? notification.bookingId ?? '',
            'name': notification.ratingData?['serviceName'] ?? 'Service',
            'serviceId': notification.ratingData?['serviceId'] ?? notification.bookingId ?? '',
            'serviceName': notification.ratingData?['serviceName'] ?? 'Service',
          },
        ),
      ),
    );
  }
}