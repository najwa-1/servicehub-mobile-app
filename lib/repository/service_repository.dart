import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('services');

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteService(String serviceId) async {
    final ratingDocs = await FirebaseFirestore.instance
        .collection('ratings')
        .where('serviceId', isEqualTo: serviceId)
        .get();

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
}
