import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';


class RatingsList extends StatelessWidget {
  final List<Map<String, dynamic>> ratings;

  const RatingsList({required this.ratings});

  @override
  Widget build(BuildContext context) {
    if (ratings.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        SizedBox(height: 8),
        ...ratings.map((rating) {
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.teal, width: 2),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:AppColors.success,
                        child: Icon(Icons.person, color:AppColors.primary),
                      ),
                      SizedBox(width: 12),
                      Text(
                        rating['name'] ?? 'Anonymous',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (rating['rating'] ?? 0) ? Icons.star : Icons.star_border,
                        color:AppColors.accent,
                        size: 20,
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  Text(
                    rating['comment'] ?? '',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  if (rating['date'] != null)
                    Text(
                      rating['date'].toString(),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
