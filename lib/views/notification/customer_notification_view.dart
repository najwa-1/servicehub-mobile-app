import 'package:flutter/material.dart';
import '../../controllers/notification/customer_notification.dart';
import '../../models/notification_model.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/notification_widgets/notification_item.dart';
import '../booking/booking_confirmation_view.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  late CustomerNotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerNotificationsController();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPendingBookingDialog(NotificationModel notification) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final booking = notification.bookingData ?? {};
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(24, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: const Color(0xFF008080),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Confirm Your Booking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(Icons.room_service, 'Service', booking['service'] ?? ''),
                            SizedBox(height: 12),
                            _buildDetailRow(Icons.calendar_today, 'Date', booking['date'] ?? ''),
                            SizedBox(height: 12),
                            _buildDetailRow(Icons.access_time, 'Time', booking['time'] ?? ''),
                            SizedBox(height: 12),
                            _buildDetailRow(Icons.location_on, 'Location', booking['location'] ?? ''),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF008080).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline, 
                              color: const Color(0xFF008080), 
                              size: 20
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'The provider has accepted your request. Please confirm to finalize your booking.',
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: const Color(0xFF008080),
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showCancelConfirmationDialog(notification);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _confirmBooking(notification);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF008080),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF008080)),
        SizedBox(width: 10),
        Text(
          '$label: ', 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Expanded(
          child: Text(
            value, 
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmationDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Cancel Booking?', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel this booking request? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Keep Booking', 
                style: TextStyle(fontWeight: FontWeight.w600)
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(notification);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Yes, Cancel', 
                style: TextStyle(fontWeight: FontWeight.w600)
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmBooking(NotificationModel notification) async {
    try {
      final bookingData = await _controller.confirmBooking(notification);
      
      if (bookingData != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationView(
              name: bookingData['name'],
              location: bookingData['location'],
              time: bookingData['time'],
              date: bookingData['date'],
              service: bookingData['service'],
              provider: bookingData['provider'],
              serviceId: bookingData['serviceId'],
            ),
          ),
        );
      }
    } catch (e) {
      print('Error confirming booking: $e');
      _showErrorDialog('Failed to confirm booking. Please try again.');
    }
  }

  Future<void> _cancelBooking(NotificationModel notification) async {
    try {
      await _controller.cancelBooking(notification);
    } catch (e) {
      print('Error cancelling booking: $e');
      _showErrorDialog('Failed to cancel booking. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                foregroundColor: Colors.white,
              ),
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    try {
      await _controller.markNotificationAsRead(notification.id);

      if (notification.type == NotificationType.bookingPendingConfirmation && 
          notification.bookingData != null) {
        _showPendingBookingDialog(notification);
      }
      else if (notification.type == NotificationType.booking && 
               notification.bookingData != null) {
        
        final bookingData = _controller.getBookingDataForNavigation(notification);
        
        if (bookingData != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationView(
                name: bookingData['name'],
                location: bookingData['location'],  
                time: bookingData['time'],
                date: bookingData['date'],
                service: bookingData['service'],
                provider: bookingData['provider'],
                serviceId: bookingData['serviceId'],
              ),
            ),
          );
        }
      }
      else {
        _controller.handleNotificationTap(notification);
      }
    } catch (e) {
      print("Failed to handle notification tap: $e");
    }
  }

  Future<void> _handleDeleteNotification(String id) async {
    try {
      await _controller.deleteNotification(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      print("Failed to delete notification: $e");
      _showErrorDialog('Failed to delete notification. Please try again.');
    }
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
          if (_controller.notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                try {
                  await _controller.markAllNotificationsAsRead();
                  _showSuccessSnackBar('All notifications marked as read');
                } catch (e) {
                  print("Failed to mark all as read: $e");
                  _showErrorDialog('Failed to mark all notifications as read.');
                }
              },
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : _controller.notifications.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: _controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _controller.notifications[index];
                    return NotificationItemWidget(
                      notification: notification,
                      onTap: (id) => _handleNotificationTap(notification),
                      onDelete: (id) => _handleDeleteNotification(id),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
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
}