import 'package:flutter/material.dart';

class RatingDetailsCard extends StatelessWidget {
  final Map<String, String> ratingData;

  const RatingDetailsCard({
    Key? key,
    required this.ratingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rating = int.tryParse(ratingData['rating'] ?? '0') ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.person, 'From', ratingData['userName'] ?? 'N/A'),
            _buildDetailRow(Icons.home_repair_service, 'Service', ratingData['serviceName'] ?? 'N/A'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, size: 20, color: Colors.teal),
                const SizedBox(width: 12),
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 28,
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text(
              'Comment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ratingData['comment'] ?? 'No comment',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}