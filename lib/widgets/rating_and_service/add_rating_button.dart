import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../views/rating/rating_page.dart';



class AddRatingButton extends StatelessWidget {
  final Map<String, dynamic> service;
  final Function(Map<String, dynamic>) onRatingSubmitted;
  static const double borderRadiusValue = 15.0;
  static const double borderWidth = 2.0;

  const AddRatingButton({required this.service, required this.onRatingSubmitted});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.star),
      label: Text('Add Rating'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          side: BorderSide(color: AppColors.primary, width: borderWidth),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingPage(
              service: service,
              onRatingSubmitted: onRatingSubmitted,
            ),
          ),
        );
      },
    );
  }
}
