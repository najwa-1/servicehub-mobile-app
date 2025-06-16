import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference ratingsCollection =
      FirebaseFirestore.instance.collection('ratings');

  Future<void> addRating(Map<String, dynamic> ratingData) async {
    await ratingsCollection.add(ratingData);
  }

  Stream<QuerySnapshot> getRatingsForService(String serviceId) {
    return ratingsCollection
        .where('serviceId', isEqualTo: serviceId)
        .snapshots();
  }
}
