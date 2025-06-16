import 'package:cloud_firestore/cloud_firestore.dart';

class addServiceRepository {
  Future<String?> addService(Map<String, dynamic> newService) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('services').add(newService);
      await docRef.update({'id': docRef.id});
      print("Service added successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error adding service: $e");
      return null;
    }
  }
}
