import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../views/rating/view_service_page.dart';


class ServiceCardWidget extends StatelessWidget {
  final Map<String, dynamic> service;
  final String role;
  final VoidCallback? onDelete;
  
  const ServiceCardWidget({required this.service, required this.role, this.onDelete,});
void _handleReport(BuildContext context, String reason) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Reported for: $reason')),
  );

  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'type': 'service_report',
      'message': 'A service was reported for: $reason',
      'reason': reason,
      'serviceName': service['name'] ?? 'Unknown',
      'serviceId': service['id'] ?? '',
      'reportedBy': service['user'] ?? 'Unknown user',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'unread',
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send report to admin: $e')),
    );
  }
}
void _showConfirmationDialog(BuildContext context, String reason) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Report'),
        content: Text('Are you sure you want to report this service as $reason?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.pop(context); 
              _handleReport(context, reason); 
            },
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(service['imageBytes'] ?? '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewServicePage(service: service)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
  children: [
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    ),
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Text(
          service['user'] ?? 'Unknown',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  if (role.toLowerCase() == 'customer')

      Positioned(
        top: -7,
        right: 8,
        child: IconButton(
          icon: Icon(Icons.flag, color: Colors.redAccent),
         onPressed: () {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Report Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text('Spam'),
             onTap: () {
          Navigator.pop(context);
          _showConfirmationDialog(context, 'Spam');
        },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.red),
              title: Text('Inappropriate'),
         onTap: () {
          Navigator.pop(context); 
          _showConfirmationDialog(context, 'Inappropriate');
        },
            ),
          ],
        ),
      );
    },
  );
},
        ),
      ),

               if (role == 'Admin' && onDelete != null)
            Positioned(
           top: -7,
        right: 8,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete Service"),
                      content: Text("Are you sure you want to delete this service?"),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete!();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
  ],
),

            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                service['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
