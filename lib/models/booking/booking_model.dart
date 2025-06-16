
class BookingModel {
  final String id;
  final String name;
  final String time;
  final String service;
  final String date;
  final String location;
  final String provider;
  final String providerId;
  final String serviceId;
  final bool isCurrentBooking;

  BookingModel({
    required this.id,
    required this.name,
    required this.time,
    required this.service,
    required this.date,
    required this.location,
    required this.provider,
    required this.providerId,
    required this.serviceId,
    required this.isCurrentBooking,
  });

  factory BookingModel.fromMap(Map<String, String> map) {
    return BookingModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      time: map['time'] ?? '',
      service: map['service'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      provider: map['provider'] ?? '',
      providerId: map['providerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      isCurrentBooking: map['isCurrentBooking'] == 'true',
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'service': service,
      'date': date,
      'location': location,
      'provider': provider,
      'providerId': providerId,
      'serviceId': serviceId,
      'isCurrentBooking': isCurrentBooking ? 'true' : 'false',
    };
  }

  BookingModel copyWith({
    String? id,
    String? name,
    String? time,
    String? service,
    String? date,
    String? location,
    String? provider,
    String? providerId,
    String? serviceId,
    bool? isCurrentBooking,
  }) {
    return BookingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      service: service ?? this.service,
      date: date ?? this.date,
      location: location ?? this.location,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      isCurrentBooking: isCurrentBooking ?? this.isCurrentBooking,
    );
  }
}