import 'package:flutter/material.dart';
import '../../models/rating.dart';


class RatingCardWidget extends StatelessWidget {
  final Rating rating;

  const RatingCardWidget({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: const BorderSide(color: Colors.teal, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: Colors.teal[100], child: const Icon(Icons.person, color: Colors.teal)),
                const SizedBox(width: 12),
                Text(rating.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(index < rating.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 20);
              }),
            ),
            const SizedBox(height: 8),
            Text(rating.comment, style: TextStyle(color: Colors.grey[700])),
            if (rating.date != null) ...[
              const SizedBox(height: 4),
              Text(rating.date!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
