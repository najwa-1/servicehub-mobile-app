import 'package:cloud_firestore/cloud_firestore.dart';

class BookingFormModel {
  final String name;
  final String phone;
  final String location;
  final String time;
  final String date;
  final String serviceName;
  final String serviceProvider;
  final String serviceId;
  final String providerId;
  final DateTime? bookingDateTime;
  final String status;
  final String clientId;

  BookingFormModel({
    required this.name,
    required this.phone,
    required this.location,
    required this.time,
    required this.date,
    required this.serviceName,
    required this.serviceProvider,
    required this.serviceId,
    required this.providerId,
    this.bookingDateTime,
    this.status = 'pending',
    required this.clientId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'location': location,
      'time': bookingDateTime != null ? Timestamp.fromDate(bookingDateTime!) : null,
      'date': date,
      'service': serviceName,
      'serviceId': serviceId,
      'provider': serviceProvider,
      'providerId': providerId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'clientId': clientId,
    };
  }

Map<String, dynamic> toNotificationData(String bookingId) {
  return {
    'title': 'New Booking Request',
    'message': '$name requested a $serviceName service',
    'time': FieldValue.serverTimestamp(),
    'isRead': false,
    'type': 'clientRequest',
    'notificationFor': 'provider',
    'receiver': serviceProvider,
    'providerId': providerId,
    'bookingId': bookingId,
    'clientId': clientId,
    'clientData': {
      'name': name,
      'phone': phone,
      'location': location,
      'service': serviceName,
      'date': date,
      'time': time,
      'notes': '',
      'clientId': clientId,
    },
  };
}


  bool isValid() {
    return name.isNotEmpty &&
        phone.isNotEmpty &&
        location.isNotEmpty &&
        time.isNotEmpty &&
        date.isNotEmpty;
  }

  BookingFormModel copyWith({
    String? name,
    String? phone,
    String? location,
    String? time,
    String? date,
    String? serviceName,
    String? serviceProvider,
    String? serviceId,
    String? providerId,
    DateTime? bookingDateTime,
    String? status,
    String? clientId,
  }) {
    return BookingFormModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      time: time ?? this.time,
      date: date ?? this.date,
      serviceName: serviceName ?? this.serviceName,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
    );
  }
}