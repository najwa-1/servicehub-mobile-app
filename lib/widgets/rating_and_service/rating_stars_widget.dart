import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';


class RatingStarsWidget extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;
 static const int numberOfStars = 5;
  static const double sizeIcon = 36;
  RatingStarsWidget({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numberOfStars, (index) {
        return IconButton(
          iconSize: sizeIcon,
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color:AppColors.primary,
          ),
          onPressed: () {
            onRatingChanged(index + 1.0);
          },
        );
      }),
    );
  }
}
