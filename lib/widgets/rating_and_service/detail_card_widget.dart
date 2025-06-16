import 'package:flutter/material.dart';

class DetailCardWidget extends StatelessWidget {
  final String title;
  final String content;

  const DetailCardWidget({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal, width: 1),
      ),
      child: Text(
        '$title: $content',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800]),
      ),
    );
  }
}
