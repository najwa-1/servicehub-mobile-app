import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    final searchCollection = _firestore.collection('search-display');
    await searchCollection.add({
      'query': query,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllServices() async {
    final snapshot = await _firestore.collection('services').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  List<Map<String, dynamic>> filterServices({
    required List<Map<String, dynamic>> services,
    required String query,
    required String selectedCategory,
  }) {
    final lowerQuery = query.toLowerCase();
    return services.where((service) {
      final name = service['name']?.toString().toLowerCase() ?? '';
      final matchQuery = name.contains(lowerQuery);
      final matchCategory =
          selectedCategory == 'All' || service['name'] == selectedCategory;
      return matchQuery && matchCategory;
    }).toList();
  }

  Future<void> deleteService(String serviceId) async {
    final ratingDocs = await _firestore
        .collection('ratings')
        .where('serviceId', isEqualTo: serviceId)
        .get();

    for (var doc in ratingDocs.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('services').doc(serviceId).delete();
  }
}
