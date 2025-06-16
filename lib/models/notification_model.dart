import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { 
  provider, 
  booking, 
  reminder, 
  promotion, 
  info, 
  clientRequest,
  approval,
  booking_rejected,

  bookingPendingConfirmation,
  bookingConfirmed,
  bookingCancelled,
  bookingCompleted,  
  rating, 

  service_report, 

}


class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;
  final Map<String, String>? providerData;
  final Map<String, String>? bookingData;
  final Map<String, String>? clientData;
  final Map<String, String>? ratingData;
  final String? userId;
  final String? clientId;
  final String? providerId;
  final String? bookingId;
  final String? serviceId;
  final Timestamp? createdAt;
  final Timestamp? timeTimestamp;
  final String? notificationFor;  

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
    this.providerData,
    this.bookingData,
    this.clientData,
    this.ratingData,
    this.userId,
    this.clientId,
    this.providerId,
    this.bookingId,
    this.serviceId,
    this.createdAt,
    this.timeTimestamp,
    this.notificationFor,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotificationType? type,
    Map<String, String>? providerData,
    Map<String, String>? bookingData,
    Map<String, String>? clientData,
    Map<String, String>? ratingData,
    String? userId,
    String? clientId,
    String? providerId,
    String? bookingId,
    String? serviceId,
    Timestamp? createdAt,
    Timestamp? timeTimestamp,
    String? notificationFor,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      providerData: providerData ?? this.providerData,
      bookingData: bookingData ?? this.bookingData,
      clientData: clientData ?? this.clientData,
      ratingData: ratingData ?? this.ratingData,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      createdAt: createdAt ?? this.createdAt,
      timeTimestamp: timeTimestamp ?? this.timeTimestamp,
      notificationFor: notificationFor ?? this.notificationFor,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    NotificationType notificationType = NotificationType.info;
    switch (data['type']) {
      case 'provider':
        notificationType = NotificationType.provider;
        break;
      case 'booking':
        notificationType = NotificationType.booking;
        break;
      case 'approval':
        notificationType = NotificationType.approval;
        break;
      case 'reminder':
        notificationType = NotificationType.reminder;
        break;
      case 'promotion':
        notificationType = NotificationType.promotion;
        break;
      case 'info':
        notificationType = NotificationType.info;
        break;
      case 'clientRequest':
        notificationType = NotificationType.clientRequest;
        break;
      case 'booking_rejected':
        notificationType = NotificationType.booking_rejected;
        break;

      case 'booking_pending_confirmation':
        notificationType = NotificationType.bookingPendingConfirmation;
        break;
      case 'booking_confirmed':
        notificationType = NotificationType.bookingConfirmed;
        break;
      case 'booking_cancelled':
      case 'bookingCancelled':  
        notificationType = NotificationType.bookingCancelled;
        break;
      case 'booking_completed':
      case 'bookingCompleted':  
        notificationType = NotificationType.bookingCompleted;
        break;
      case 'rating':
        notificationType = NotificationType.rating;
        break;
               case 'service_report':
    notificationType = NotificationType.service_report; 
    break;
      default:
        notificationType = NotificationType.info;
        break;



    }

    
    Timestamp? createdAtTimestamp;
    Timestamp? timeTimestamp;
    
    if (data['createdAt'] != null) {
      try {
        createdAtTimestamp = data['createdAt'] as Timestamp;
      } catch (e) {
       
        createdAtTimestamp = null;
      }
    }
    
    if (data['time'] != null) {
      try {
        timeTimestamp = data['time'] as Timestamp;
      } catch (e) {
        timeTimestamp = null;
      }
    }

    String formattedTime = 'Just now';
    final timestampToUse = createdAtTimestamp ?? timeTimestamp;
    
    if (timestampToUse != null) {
      final now = Timestamp.now();
      final difference = now.seconds - timestampToUse.seconds;
      
      if (difference < 60) {
        formattedTime = 'Just now';
      } else if (difference < 3600) {
        final minutes = (difference / 60).floor();
        formattedTime = '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference < 86400) {
        final hours = (difference / 3600).floor();
        formattedTime = '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference < 172800) {
        formattedTime = 'Yesterday';
      } else {
        final days = (difference / 86400).floor();
        formattedTime = '$days ${days == 1 ? 'day' : 'days'} ago';
      }
    }

    Map<String, String>? providerData;
    Map<String, String>? bookingData;
    Map<String, String>? clientData;
    Map<String, String>? ratingData;
    
    if (data['providerData'] != null) {
      try {
        providerData = Map<String, String>.from(
          (data['providerData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value?.toString() ?? '')
          )
        );
      } catch (e) {
        providerData = null;
      }
    }
    
    if (data['bookingData'] != null) {
      try {
        bookingData = Map<String, String>.from(
          (data['bookingData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value?.toString() ?? '')
          )
        );
      } catch (e) {
        bookingData = null;
      }
    }
    
    if (data['clientData'] != null) {
      try {
        clientData = Map<String, String>.from(
          (data['clientData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value?.toString() ?? '')
          )
        );
      } catch (e) {
        clientData = null;
      }
    }

    if (data['ratingData'] != null) {
      try {
        ratingData = Map<String, String>.from(
          (data['ratingData'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, value?.toString() ?? '')
          )
        );
      } catch (e) {
        ratingData = null;
      }
    }

    return NotificationModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      time: formattedTime,
      isRead: data['isRead'] == true,
      type: notificationType,
      providerData: providerData,
      bookingData: bookingData,
      clientData: clientData,
      ratingData: ratingData,
      userId: data['userId']?.toString(),
      clientId: data['clientId']?.toString(),
      providerId: data['providerId']?.toString(),
      bookingId: data['bookingId']?.toString(),
      serviceId: data['serviceId']?.toString(),
      createdAt: createdAtTimestamp,
      timeTimestamp: timeTimestamp,
      notificationFor: data['notificationFor']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    String typeString;
    switch (type) {
      case NotificationType.provider:
        typeString = 'provider';
        break;
      case NotificationType.booking:
        typeString = 'booking';
        break;
      case NotificationType.approval:
        typeString = 'approval';
        break;
      case NotificationType.reminder:
        typeString = 'reminder';
        break;
      case NotificationType.promotion:
        typeString = 'promotion';
        break;
      case NotificationType.info:
        typeString = 'info';
        break;
      case NotificationType.clientRequest:
        typeString = 'clientRequest';
        break;
      case NotificationType.booking_rejected:
        typeString = 'booking_rejected';
        break;

      case NotificationType.bookingPendingConfirmation:
        typeString = 'booking_pending_confirmation';
        break;
      case NotificationType.bookingConfirmed:
        typeString = 'booking_confirmed';
        break;
      case NotificationType.bookingCancelled:
        typeString = 'bookingCancelled';
        break;
      case NotificationType.bookingCompleted:
        typeString = 'bookingCompleted';
        break;
      case NotificationType.rating:
        typeString = 'rating';
        break;

        case NotificationType.service_report:
    typeString = 'service_report'; 
    break;
    }

    final Map<String, dynamic> firestoreData = {
      'title': title,
      'message': message,
      'isRead': isRead,
      'type': typeString,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'time': timeTimestamp ?? FieldValue.serverTimestamp(),
    };

    if (providerData != null && providerData!.isNotEmpty) {
      firestoreData['providerData'] = providerData;
    }
    if (bookingData != null && bookingData!.isNotEmpty) {
      firestoreData['bookingData'] = bookingData;
    }
    if (clientData != null && clientData!.isNotEmpty) {
      firestoreData['clientData'] = clientData;
    }
    if (ratingData != null && ratingData!.isNotEmpty) {
      firestoreData['ratingData'] = ratingData;
    }
    if (userId != null && userId!.isNotEmpty) {
      firestoreData['userId'] = userId;
    }
    if (clientId != null && clientId!.isNotEmpty) {
      firestoreData['clientId'] = clientId;
    }
    if (providerId != null && providerId!.isNotEmpty) {
      firestoreData['providerId'] = providerId;
    }
    if (bookingId != null && bookingId!.isNotEmpty) {
      firestoreData['bookingId'] = bookingId;
    }
    if (serviceId != null && serviceId!.isNotEmpty) {
      firestoreData['serviceId'] = serviceId;
    }
    if (notificationFor != null && notificationFor!.isNotEmpty) {
      firestoreData['notificationFor'] = notificationFor;
    }

    return firestoreData;
  }

  bool get isForClient => 
    clientId != null && 
    clientId!.isNotEmpty && 
    notificationFor != 'provider';

  bool get isForProvider => 
    providerId != null && 
    providerId!.isNotEmpty && 
    notificationFor != 'client';

  String get notificationIcon {
    switch (type) {
      case NotificationType.booking:
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingPendingConfirmation:
        return '📅';
      case NotificationType.bookingCancelled:
        return '❌';
      case NotificationType.bookingCompleted:
        return '✅';
      case NotificationType.clientRequest:
        return '👤';
      case NotificationType.rating:
        return '⭐';
      case NotificationType.approval:
        return '✔️';
      case NotificationType.booking_rejected:
        return '❌';
      case NotificationType.reminder:
        return '🔔';
      case NotificationType.promotion:
        return '🎉';
      case NotificationType.provider:
        return '🏪';
      case NotificationType.info:
      default:
        return 'ℹ️';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, clientId: $clientId, providerId: $providerId, notificationFor: $notificationFor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}