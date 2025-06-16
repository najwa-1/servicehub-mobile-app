import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service/sevivceModel.dart';


class FirebaseServiceProvider {
  static final _collection = FirebaseFirestore.instance.collection('services');

  static Future<List<ServiceModel>> getAllServices() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ServiceModel.fromMap(data, doc.id);
    }).toList();
  }

  static Future<ServiceModel?> getServiceById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return ServiceModel.fromMap(doc.data()!, doc.id);
  }

  static Future<void> deleteServiceAndRatings(String serviceId) async {
    final ratingDocs = await FirebaseFirestore.instance
        .collection('ratings')
        .where('serviceId', isEqualTo: serviceId)
        .get();

    for (var doc in ratingDocs.docs) {
      await doc.reference.delete();
    }

    await _collection.doc(serviceId).delete();
  }

  static Future<void> updateService(String serviceId, ServiceModel service) async {
    await _collection.doc(serviceId).update(service.toMap());
  }

  static Future<ServiceModel> getDocumentById(String docId) async {
    final doc = await _collection.doc(docId).get();
    return ServiceModel.fromMap(doc.data()!, doc.id);
  }
}
