import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class NameFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  NameFieldWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Your Name',
        prefixIcon: Icon(Icons.person, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor:AppColors.background,
      ),
    );
  }
}
