import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/ratingFirebase.dart';
import '../services/notification_service.dart';

class RatingRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> submitRating({
    required BuildContext context,
    required Map<String, dynamic> service,
    required String name,
    required String comment,
    required double rating,
    required Function(Map<String, dynamic>) onRatingSubmitted,
  }) async {
    if (name.isEmpty || rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            name.isEmpty ? 'Please enter your name' : 'Please select a rating',
          ),
        ),
      );
      return;
    }

    final newRating = {
      'name': name,
      'comment': comment,
      'rating': rating,
      'date': DateTime.now().toIso8601String(),
      'serviceId': service['id'],
    };

    try {
      await _firebaseService.addRating(newRating);
      
      print('Service data: $service');
      
      String? providerId = service['providerId'] ?? 
                          service['provider_id'] ?? 
                          service['providerID'] ?? 
                          service['uid'] ??
                          service['userId'];
      
      print('Found provider ID: $providerId');
      
      if (providerId == null || providerId.isEmpty) {
        try {
          DocumentSnapshot serviceDoc = await _firestore
              .collection('services')
              .doc(service['id'])
              .get();
          
          if (serviceDoc.exists) {
            Map<String, dynamic> serviceData = serviceDoc.data() as Map<String, dynamic>;
            providerId = serviceData['providerId'] ?? 
                        serviceData['provider_id'] ?? 
                        serviceData['providerID'] ?? 
                        serviceData['uid'] ??
                        serviceData['userId'];
            
            print('Provider ID from Firestore: $providerId');
          }
        } catch (e) {
          print('Error fetching service document: $e');
        }
      }
      
      if (providerId == null || providerId.isEmpty) {
        try {
          QuerySnapshot providersQuery = await _firestore
              .collection('providers')
              .where('services', arrayContains: service['id'])
              .get();
          
          if (providersQuery.docs.isNotEmpty) {
            providerId = providersQuery.docs.first.id;
            print('Provider ID from providers collection: $providerId');
          }
        } catch (e) {
          print('Error querying providers collection: $e');
        }
      }
      
      if (providerId != null && providerId.isNotEmpty) {
        print('Sending notification to provider: $providerId');
        
        await _notificationService.sendRatingNotificationToProvider(
          providerId: providerId,
          serviceId: service['id'] ?? '',
          serviceName: service['name'] ?? service['serviceName'] ?? 'Your Service',
          clientName: name,
          rating: rating,
          comment: comment,
        );
        
        print('Notification sent successfully');
      } else {
        print('ERROR: Could not find provider ID for service: ${service['id']}');
        print('Available service keys: ${service.keys.toList()}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rating submitted but notification could not be sent to provider'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      onRatingSubmitted(newRating);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $e')),
      );
    }
  }

  Stream getServiceRatings(String serviceId) {
    return _firebaseService.getRatingsForService(serviceId);
  }
}