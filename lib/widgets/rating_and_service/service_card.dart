import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../views/rating/view_service_page.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (service['imageBytes'] != null && service['imageBytes'] != "") {
      imageBytes = base64Decode(service['imageBytes']);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewServicePage(service: service)),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: imageBytes != null
                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 50, color: Colors.teal),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    service['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.teal[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.teal),
                            SizedBox(height: 4),
                            Text('edit',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, color: Colors.red[400]),
                            SizedBox(height: 4),
                            Text('delete',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
