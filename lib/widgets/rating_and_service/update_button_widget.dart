import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class UpdateButtonWidget extends StatelessWidget {
  final Function() onPressed;
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 12.0;
  static const double fontSizeValue = 16.0;
  static const double borderRadiusValue = 10.0;


  UpdateButtonWidget({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        child: Text(
          'Update',
          style: TextStyle(fontSize: fontSizeValue, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
      ),
    );
  }
}
