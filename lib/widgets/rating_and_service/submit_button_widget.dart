import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SubmitButtonWidget extends StatelessWidget {
  final Function() onPressed;
   static const double verticalPadding = 14.0;
  static const double borderRadiusValue = 12.0;
  static const double fontSizeValue = 16.0;
  static const double iconSpacing = 8.0;

  SubmitButtonWidget({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadiusValue)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Submit Rating',
              style: TextStyle(fontSize: fontSizeValue, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: iconSpacing),
            Icon(Icons.send),
          ],
        ),
      ),
    );
  }
}
