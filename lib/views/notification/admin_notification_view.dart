import 'package:flutter/material.dart';

import '../../controllers/notification/admin_notification.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_widgets/notification_item.dart';
import '../../widgets/notification_widgets/provider_details_card.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  late AdminNotificationsController controller;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    controller = AdminNotificationsController(context);
    controller.listenToNotifications((updatedNotifications) {
      setState(() {
        notifications = updatedNotifications;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItemWidget(
                  notification: notification,
                  onTap: (id) {
                    controller.markAsRead(id);
                    if (notification.type == NotificationType.provider &&
                        notification.providerData != null) {
                      _showProviderDetailsPopup(
                        context,
                        notification.providerData!,
                        notification.id,
                      );
                    } else if (notification.type == NotificationType.service_report) {
                      controller.showReportDetailsDialog(notification);
                    }
                  },
                  onDelete: controller.deleteNotification,
                );
              },
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any notifications at the moment',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showProviderDetailsPopup(
    BuildContext context,
    Map<String, String> providerData,
    String notificationId,
  ) {
    final providerId = providerData['providerId'];

    if (providerId == null || providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider ID is missing')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Provider Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProviderDetailsCard(providerData: providerData),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await controller.rejectProvider(providerId, notificationId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await controller.approveProvider(providerId, notificationId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}