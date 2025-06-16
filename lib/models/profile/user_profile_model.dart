import 'dart:typed_data';

class UserProfile {
  String firstName;
  String lastName;
  String phoneNumber;
  String location;
  Uint8List? profileImage;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.location,
    this.profileImage,
  });
}
