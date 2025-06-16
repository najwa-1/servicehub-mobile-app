class CustomerProfile {
  final String firstName;
  final String lastName;
  final String phone;
  final String location;
  final String? profileImageBase64;

  CustomerProfile({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.location,
    this.profileImageBase64,
  });

  factory CustomerProfile.fromFirestore(Map<String, dynamic> data, String location) {
    return CustomerProfile(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? '',
      location: location,
      profileImageBase64: data['profileImage'],
    );
  }
}
