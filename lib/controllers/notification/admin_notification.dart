import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/notification_model.dart';

class AdminNotificationsController {
  final BuildContext context;
  List<NotificationModel> notifications = [];

  AdminNotificationsController(this.context);

  void listenToNotifications(Function(List<NotificationModel>) onNotificationsChanged) {
    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final timeAgo = _getTimeAgo(timestamp?.toDate());

        return NotificationModel(
          id: doc.id,
          title: data['type'] == 'provider_signup'
              ? 'New Provider Request'
              : data['type'] == 'service_report'
                  ? 'Service Reported'
                  : 'Notification',
          message: data['type'] == 'provider_signup'
              ? '${data['providerName'] ?? 'A provider'} has signed up for approval'
              : data['type'] == 'service_report'
                  ? 'Service "${data['serviceName'] ?? 'Unknown'}" was reported for ${data['reason'] ?? 'unknown reason'}'
                  : '',
          time: timeAgo,
          isRead: data['status'] == 'read',
          type: data['type'] == 'provider_signup'
              ? NotificationType.provider
              : NotificationType.service_report,
          providerData: data['type'] == 'provider_signup'
              ? {
                  'name': data['providerName'] ?? '',
                  'providerId': data['providerId'] ?? '',
                  'email': '',
                  'phone': '',
                  'specialty': '',
                  'experience': '',
                  'location': '',
                  'rating': '',
                  'availability': '',
                }
              : null,
        );
      }).toList();
      
      onNotificationsChanged(notifications);
    });
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'some time ago';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update({
      'status': 'read',
    });
  }

  Future<void> markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final notification in notifications) {
      final docRef =
          FirebaseFirestore.instance.collection('notifications').doc(notification.id);
      batch.update(docRef, {'status': 'read'});
    }
    await batch.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  Future<void> deleteNotification(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  void showReportDetailsDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Service Report'),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          )
        ],
      ),
    );
  }

  Future<void> approveProvider(String providerId, String notificationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(providerId)
        .update({'status': 'approved'});
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'status': 'read'});
  }

  Future<void> rejectProvider(String providerId, String notificationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Rejection'),
        content: const Text('Are you sure you want to reject this service provider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(providerId)
          .update({'status': 'rejected'});
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'status': 'read'});
    }
  }
}