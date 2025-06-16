import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? service;
  final String? date;
  final String? time;
  final String? location;
  final String? status;
  final String? notes;
  final String? profileImage;
  final String? clientId;
  final Timestamp? timestamp;

  ClientModel({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.service,
    this.date,
    this.time,
    this.location,
    this.status,
    this.notes,
    this.profileImage,
    this.clientId,
    this.timestamp,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ClientModel(
      id: documentId,
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      service: map['service'],
      date: map['date'],
      time: map['time'],
      location: map['location'],
      status: map['status'],
      notes: map['notes'],
      profileImage: map['profileImage'],
      clientId: map['clientId'],
      timestamp: map['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'service': service,
      'date': date,
      'time': time,
      'location': location,
      'status': status,
      'notes': notes,
      'profileImage': profileImage,
      'clientId': clientId,
      'timestamp': timestamp,
    };
  }

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? service,
    String? date,
    String? time,
    String? location,
    String? status,
    String? notes,
    String? profileImage,
    String? clientId,
    Timestamp? timestamp,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      profileImage: profileImage ?? this.profileImage,
      clientId: clientId ?? this.clientId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}