import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class updateServiceRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('services');
  final CollectionReference _ratingCollection = FirebaseFirestore.instance.collection('ratings');

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteService(String serviceId) async {
    final ratingDocs = await _ratingCollection.where('serviceId', isEqualTo: serviceId).get();
    for (var doc in ratingDocs.docs) {
      await doc.reference.delete();
    }
    await _collection.doc(serviceId).delete();
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> updatedData) async {
    await _collection.doc(serviceId).update(updatedData);
  }

  Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
    final doc = await _collection.doc(serviceId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  Future<String> addService(Map<String, dynamic> newService) async {
    final docRef = await _collection.add(newService);
    return docRef.id;
  }

  Future<Uint8List?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
      return null;
    } catch (e) {
      throw Exception('فشل في اختيار الصورة: ${e.toString()}');
    }
  }


  Future<void> submitUpdate(String serviceId, Map<String, dynamic> updatedData) async {
    if (updatedData['name'] == null || updatedData['name'].toString().isEmpty ||
        updatedData['details'] == null || updatedData['details'].toString().isEmpty ||
        updatedData['price'] == null || updatedData['price'].toString().isEmpty) {
      throw Exception('Sure yo fill all fields');
    }

    await updateService(serviceId, updatedData);
  }
}
