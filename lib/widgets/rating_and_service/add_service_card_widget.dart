import 'package:flutter/material.dart';

class AddServiceCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddServiceCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromARGB(255, 248, 253, 252).withOpacity(0.1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.teal, size: 40),
                SizedBox(height: 8.0),
                Text("Add Service",
                    style: TextStyle(
                        color: Colors.teal[700], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
