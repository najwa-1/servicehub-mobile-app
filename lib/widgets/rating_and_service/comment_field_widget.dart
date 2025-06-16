import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CommentFieldWidget extends StatelessWidget {
  final TextEditingController controller;
 static const double borderRadiusValue = 15.0;
  CommentFieldWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Your Comment (optional)',
        prefixIcon: Icon(Icons.comment, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadiusValue)),
        filled: true,
        fillColor:AppColors.background,
      ),
      maxLines: 4,
    );
  }
}
