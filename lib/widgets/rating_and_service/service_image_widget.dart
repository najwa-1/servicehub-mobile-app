import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ServiceImageWidget extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceImageWidget({required this.service});

  @override
  Widget build(BuildContext context) {
    try {
      if (service['imageBytes'] != null && service['imageBytes'].isNotEmpty) {
        return Image.memory(base64Decode(service['imageBytes']), fit: BoxFit.cover, width: 160, height: 160);
      } else if (service['imageUrl'] != null && service['imageUrl'].isNotEmpty) {
        return Image.network(service['imageUrl'], fit: BoxFit.cover, width: 160, height: 160);
      } else if (!kIsWeb && service['imagePath'] != null && service['imagePath'].isNotEmpty) {
        return Image.file(File(service['imagePath']), fit: BoxFit.cover, width: 160, height: 160);
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return Container(
      width: 160,
      height: 160,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image, size: 60, color: Colors.teal)),
    );
  }
}
