
class BookingConfirmationModel {
  final String name;
  final String location;
  final String time;
  final String date;
  final String service;
  final String provider; 
  final String serviceId;
  final String? bookingId;
  final String providerName;
  final String clientId;
  final String status;
  final DateTime? timestamp;

  BookingConfirmationModel({
    required this.name,
    required this.location,
    required this.time,
    required this.date,
    required this.service,
    required this.provider,
    required this.serviceId,
    this.bookingId,
    this.providerName = '',
    this.clientId = '',
    this.status = 'active',
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'time': time,
      'date': date,
      'service': service,
      'provider': provider,
      'providerName': providerName,
      'serviceId': serviceId,
      'clientId': clientId,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory BookingConfirmationModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingConfirmationModel(
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      service: map['service'] ?? '',
      provider: map['provider'] ?? '',
      serviceId: map['serviceId'] ?? '',
      bookingId: id,
      providerName: map['providerName'] ?? '',
      clientId: map['clientId'] ?? '',
      status: map['status'] ?? 'active',
      timestamp: map['timestamp']?.toDate(),
    );
  }

  Map<String, String> toDisplayData() {
    return {
      'name': name,
      'service': service,
      'provider': providerName.isNotEmpty ? providerName : provider,
      'location': location,
      'date': date,
      'time': time,
      'serviceId': serviceId,
      'id': bookingId ?? '',
      'providerId': provider,
    };
  }

  BookingConfirmationModel copyWith({
    String? name,
    String? location,
    String? time,
    String? date,
    String? service,
    String? provider,
    String? serviceId,
    String? bookingId,
    String? providerName,
    String? clientId,
    String? status,
    DateTime? timestamp,
  }) {
    return BookingConfirmationModel(
      name: name ?? this.name,
      location: location ?? this.location,
      time: time ?? this.time,
      date: date ?? this.date,
      service: service ?? this.service,
      provider: provider ?? this.provider,
      serviceId: serviceId ?? this.serviceId,
      bookingId: bookingId ?? this.bookingId,
      providerName: providerName ?? this.providerName,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String name;

  UserModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.name = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }

  String get fullName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (name.isNotEmpty) {
      return name;
    } else {
      return '';
    }
  }
}