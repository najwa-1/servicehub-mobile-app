import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  Future<Uint8List?> fetchUserProfileImage(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      if (data != null &&
          data['profileImage'] != null &&
          data['profileImage'].isNotEmpty) {
        return base64Decode(data['profileImage']);
      }
    } catch (e) {
      print("Error fetching profile image for $userId: $e");
    }
    return null;
  }


  Future<Map<String, Uint8List?>> preloadProfileImagesFromServices(
      List<Map<String, dynamic>> services) async {
    final userIds = services
        .map((service) => service['userId'] as String?)
        .whereType<String>()
        .toSet();

    Map<String, Uint8List?> imageMap = {};

    for (final userId in userIds) {
      final image = await fetchUserProfileImage(userId);
      imageMap[userId] = image;
    }

    return imageMap;
  }

 
  List<Map<String, dynamic>> filterServicesByProvider(
      List<Map<String, dynamic>> services, String query) {
    final lowerQuery = query.toLowerCase();
    return services.where((service) {
      final user = service['user']?.toString().toLowerCase() ?? '';
      return user.contains(lowerQuery);
    }).toList();
  }
}
