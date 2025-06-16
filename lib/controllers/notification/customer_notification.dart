import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class CustomerNotificationsController extends ChangeNotifier {
  List<NotificationModel> notifications = [];
  final NotificationService _notificationService = NotificationService();
  bool isLoading = true;
  static Map<String, String> _providerNames = {};

  CustomerNotificationsController() {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationService.getClientNotifications().listen((updatedNotifications) {
      notifications = updatedNotifications;
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print("Customer notification stream error: $e");
      isLoading = false;
      notifyListeners();
    });
  }

  Future<String> getProviderName(String providerId) async {
    print('Getting provider name for ID: $providerId');
    
    if (_providerNames.containsKey(providerId)) {
      print('Found in cache: ${_providerNames[providerId]}');
      return _providerNames[providerId]!;
    }

    try {
      print('Fetching from Firestore...');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        print('User document data: $data');
        
        String fullName = _extractFullName(data);
        print('Extracted full name: $fullName');
        
        _providerNames[providerId] = fullName;
        return fullName;
      } else {
        print('User document does not exist for ID: $providerId');
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
    if (data == null) {
      print('Data is null');
      return '';
    }
    
    String firstName = data['firstName']?.toString() ?? '';
    String lastName = data['lastName']?.toString() ?? '';
    String nameField = data['name']?.toString() ?? '';
    
    print('firstName: $firstName, lastName: $lastName, name: $nameField');
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (nameField.isNotEmpty) {
      return nameField;
    } else {
      return '';
    }
  }

  Future<Map<String, dynamic>?> confirmBooking(NotificationModel notification) async {
    try {
      final booking = notification.bookingData!;
      final providerId = booking['providerID']?.toString() ?? booking['provider']?.toString() ?? '';
      
      print('Confirming booking with data: $booking');
      print('Provider ID: $providerId');
      
      await FirebaseFirestore.instance.collection('bookingnow').add({
        'name': booking['name'] ?? '',
        'service': booking['service'] ?? '',
        'provider': providerId,
        'location': booking['location'] ?? '',
        'date': booking['date'] ?? '',
        'time': booking['time'] ?? '',
        'serviceId': booking['serviceId'] ?? '',
        'clientId': _notificationService.currentUserId ?? '',
        'bookingId': booking['bookingId'] ?? '',
        'status': 'confirmed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _notificationService.removePendingBooking(
        _notificationService.currentUserId ?? '',
        providerId
      );

      if (providerId.isNotEmpty) {
        await _notificationService.sendNotificationToProvider(
          providerId: providerId,
          title: 'Booking Confirmed',
          message: 'Customer has confirmed the booking request',
          bookingData: Map<String, dynamic>.from(booking),
          type: 'booking_confirmed',
          bookingId: booking['bookingId']?.toString()
        );
      }

      await _notificationService.markAsRead(notification.id);

      return {
        'name': booking['name']?.toString() ?? '',
        'location': booking['location']?.toString() ?? '',
        'time': booking['time']?.toString() ?? '',
        'date': booking['date']?.toString() ?? '',
        'service': booking['service']?.toString() ?? '',
        'provider': providerId,
        'serviceId': booking['serviceId']?.toString() ?? '',
      };

    } catch (e) {
      print('Error confirming booking: $e');
      rethrow;
    }
  }

  Future<void> cancelBooking(NotificationModel notification) async {
    try {
      final booking = notification.bookingData!;
      final providerId = booking['providerID']?.toString() ?? booking['provider']?.toString() ?? '';
      
      print('Cancelling booking with data: $booking');
      print('Provider ID: $providerId');
      
      await _notificationService.removePendingBooking(
        _notificationService.currentUserId ?? '',
        providerId
      );

      if (providerId.isNotEmpty) {
        await _notificationService.sendNotificationToProvider(
          providerId: providerId,
          title: 'Booking Cancelled',
          message: 'Customer has cancelled the booking request',
          bookingData: Map<String, dynamic>.from(booking),
          type: 'booking_cancelled',
          bookingId: booking['bookingId']?.toString()
        );
      }

      await _notificationService.markAsRead(notification.id);

    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      print("Marked as read: $id");
    } catch (e) {
      print("Failed to mark as read: $e");
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _notificationService.markAllAsRead(notifications);
    } catch (e) {
      print("Failed to mark all as read: $e");
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
    } catch (e) {
      print("Failed to delete notification: $e");
      rethrow;
    }
  }

  Map<String, dynamic>? getBookingDataForNavigation(NotificationModel notification) {
    if (notification.type != NotificationType.booking || notification.bookingData == null) {
      return null;
    }

    final booking = notification.bookingData!;
    
    String providerId = '';
    
    if (booking.containsKey('providerID') && booking['providerID'] != null && booking['providerID'].toString().isNotEmpty) {
      providerId = booking['providerID'].toString();
    } else if (booking.containsKey('provider') && booking['provider'] != null && booking['provider'].toString().isNotEmpty) {
      providerId = booking['provider'].toString();
    } else if (booking.containsKey('receiver') && booking['receiver'] != null && booking['receiver'].toString().isNotEmpty) {
      providerId = booking['receiver'].toString();
    }

    print('Provider ID found: $providerId');
    print('Booking data: $booking');

    return {
      'name': booking['name']?.toString() ?? '',
      'location': booking['location']?.toString() ?? '',
      'time': booking['time']?.toString() ?? '',
      'date': booking['date']?.toString() ?? '',
      'service': booking['service']?.toString() ?? '',
      'provider': providerId,
      'serviceId': booking['serviceId']?.toString() ?? '',
    };
  }

  void handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.booking_rejected:
        print('Booking rejection notification tapped');
        break;
      case NotificationType.approval:
        print('Approval notification tapped');
        break;
      case NotificationType.info:
        print('Info notification tapped: ${notification.message}');
        break;
      case NotificationType.bookingCompleted:
        print('Booking completed notification tapped');
        break;
      case NotificationType.bookingCancelled:
        print('Booking cancelled notification tapped');
        break;
      default:
        print('Unknown notification type tapped');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}