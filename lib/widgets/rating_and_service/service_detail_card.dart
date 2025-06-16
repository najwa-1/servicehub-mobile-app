import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ServiceDetailCard extends StatelessWidget {
  final String title;
  final String value;

  const ServiceDetailCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Text(
        '$title: $value',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:AppColors.secondary),
      ),
    );
  }
}
