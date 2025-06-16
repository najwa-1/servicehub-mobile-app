import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class NotificationItemWidget extends StatefulWidget {
  final NotificationModel notification;
  final Function(String) onTap;
  final Function(String) onDelete;

  const NotificationItemWidget({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationStyle = _getNotificationStyle(widget.notification.type, widget.notification.message);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dismissible(
        key: Key(widget.notification.id),
        background: _buildDismissBackground(),
        confirmDismiss: (direction) => _showDeleteConfirmation(context),
        onDismissed: (direction) => widget.onDelete(widget.notification.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Material(
            elevation: widget.notification.isRead ? 1 : 4,
            shadowColor: Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: widget.notification.isRead 
                  ? Colors.white 
                  : notificationStyle.backgroundColor,
                border: widget.notification.isRead 
                  ? Border.all(color: Colors.grey.shade200, width: 1)
                  : Border.all(
                      color: notificationStyle.borderColor,
                      width: 1.5,
                    ),
              ),
              child: InkWell(
                onTap: () => widget.onTap(widget.notification.id),
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(12),
                splashColor: notificationStyle.iconColor.withOpacity(0.1),
                highlightColor: notificationStyle.iconColor.withOpacity(0.05),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIconContainer(notificationStyle),
                          const SizedBox(width: 12),
                          Expanded(child: _buildContent(notificationStyle)),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildCloseButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(NotificationStyle notificationStyle) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: notificationStyle.iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: notificationStyle.iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        notificationStyle.icon,
        color: notificationStyle.iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildContent(NotificationStyle notificationStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleAndTime(),
        const SizedBox(height: 6),
        _buildMessage(),
        const SizedBox(height: 10),
        _buildStatusAndIndicator(notificationStyle),
      ],
    );
  }

  Widget _buildTitleAndTime() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.notification.title,
            style: TextStyle(
              fontWeight: widget.notification.isRead 
                ? FontWeight.w500 
                : FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.notification.time,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      widget.notification.message,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 13,
        height: 1.3,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusAndIndicator(NotificationStyle notificationStyle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: notificationStyle.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            notificationStyle.statusText,
            style: TextStyle(
              color: notificationStyle.statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!widget.notification.isRead) _buildUnreadIndicator(),
      ],
    );
  }

  Widget _buildUnreadIndicator() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF008080),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008080).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDeleteConfirmation(context).then((confirm) {
          if (confirm == true) {
            widget.onDelete(widget.notification.id);
          }
        }),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.close,
            size: 16,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Delete Notification",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete this notification? This action cannot be undone.",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  NotificationStyle _getNotificationStyle(NotificationType type, String message) {
    if (type == NotificationType.info) {
      final lowerMessage = message.toLowerCase();
      if (lowerMessage.contains('completed') || lowerMessage.contains('success')) {
        return NotificationStyle(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF388E3C),
          backgroundColor: const Color(0xFF388E3C).withOpacity(0.04),
          borderColor: const Color(0xFF388E3C).withOpacity(0.3),
          statusColor: const Color(0xFF388E3C),
          statusText: 'Completed',
        );
      } else if (lowerMessage.contains('cancel') || lowerMessage.contains('delete')) {
        return NotificationStyle(
          icon: Icons.cancel_outlined,
          iconColor: const Color(0xFFD32F2F),
          backgroundColor: const Color(0xFFD32F2F).withOpacity(0.04),
          borderColor: const Color(0xFFD32F2F).withOpacity(0.3),
          statusColor: const Color(0xFFD32F2F),
          statusText: 'Cancelled',
        );
      }
    }

    switch (type) {
      case NotificationType.booking:
      case NotificationType.bookingPendingConfirmation:
        return NotificationStyle(
          icon: Icons.event_note_outlined,
          iconColor: const Color(0xFF008080),
          backgroundColor: const Color(0xFF008080).withOpacity(0.04),
          borderColor: const Color(0xFF008080).withOpacity(0.3),
          statusColor: const Color(0xFF008080),
          statusText: 'Booking',
        );
        
      case NotificationType.bookingConfirmed:
        return NotificationStyle(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF388E3C),
          backgroundColor: const Color(0xFF388E3C).withOpacity(0.04),
          borderColor: const Color(0xFF388E3C).withOpacity(0.3),
          statusColor: const Color(0xFF388E3C),
          statusText: 'Confirmed',
        );
        
      case NotificationType.bookingCompleted:
        return NotificationStyle(
          icon: Icons.task_alt,
          iconColor: const Color(0xFF00695C),
          backgroundColor: const Color(0xFF00695C).withOpacity(0.04),
          borderColor: const Color(0xFF00695C).withOpacity(0.3),
          statusColor: const Color(0xFF00695C),
          statusText: 'Completed',
        );
        
      case NotificationType.bookingCancelled:
      case NotificationType.booking_rejected:
        return NotificationStyle(
          icon: Icons.cancel_outlined,
          iconColor: const Color(0xFFD32F2F),
          backgroundColor: const Color(0xFFD32F2F).withOpacity(0.04),
          borderColor: const Color(0xFFD32F2F).withOpacity(0.3),
          statusColor: const Color(0xFFD32F2F),
          statusText: 'Cancelled',
        );
        
      case NotificationType.rating:
        return NotificationStyle(
          icon: Icons.star_outline,
          iconColor: const Color(0xFFF57C00),
          backgroundColor: const Color(0xFFF57C00).withOpacity(0.04),
          borderColor: const Color(0xFFFF9800).withOpacity(0.3),
          statusColor: const Color(0xFFF57C00),
          statusText: 'Rating',
        );
        
      case NotificationType.clientRequest:
        return NotificationStyle(
          icon: Icons.person_add_outlined,
          iconColor: const Color(0xFF004D4D),
          backgroundColor: const Color(0xFF004D4D).withOpacity(0.04),
          borderColor: const Color(0xFF004D4D).withOpacity(0.3),
          statusColor: const Color(0xFF004D4D),
          statusText: 'Request',
        );
        
      case NotificationType.provider:
        return NotificationStyle(
          icon: Icons.store_outlined,
          iconColor: const Color(0xFF008080),
          backgroundColor: const Color(0xFF008080).withOpacity(0.04),
          borderColor: const Color(0xFF008080).withOpacity(0.3),
          statusColor: const Color(0xFF008080),
          statusText: 'Provider',
        );
        
      case NotificationType.approval:
        return NotificationStyle(
          icon: Icons.verified_outlined,
          iconColor: const Color(0xFF388E3C),
          backgroundColor: const Color(0xFF388E3C).withOpacity(0.04),
          borderColor: const Color(0xFF388E3C).withOpacity(0.3),
          statusColor: const Color(0xFF388E3C),
          statusText: 'Approved',
        );
        
      case NotificationType.reminder:
        return NotificationStyle(
          icon: Icons.schedule_outlined,
          iconColor: const Color(0xFFE65100),
          backgroundColor: const Color(0xFFE65100).withOpacity(0.04),
          borderColor: const Color(0xFFE65100).withOpacity(0.3),
          statusColor: const Color(0xFFE65100),
          statusText: 'Reminder',
        );
        
      case NotificationType.promotion:
        return NotificationStyle(
          icon: Icons.local_offer_outlined,
          iconColor: const Color(0xFF7B1FA2),
          backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.04),
          borderColor: const Color(0xFF7B1FA2).withOpacity(0.3),
          statusColor: const Color(0xFF7B1FA2),
          statusText: 'Offer',
        );
        
      case NotificationType.info:
      default:
        return NotificationStyle(
          icon: Icons.info_outline,
          iconColor: const Color(0xFF1976D2),
          backgroundColor: const Color(0xFF1976D2).withOpacity(0.04),
          borderColor: const Color(0xFF1976D2).withOpacity(0.3),
          statusColor: const Color(0xFF1976D2),
          statusText: 'Info',
        );
    }
  }
}

class NotificationStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color statusColor;
  final String statusText;

  NotificationStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.statusColor,
    required this.statusText,
  });
}