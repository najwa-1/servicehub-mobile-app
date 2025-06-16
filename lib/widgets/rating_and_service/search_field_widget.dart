import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSubmitted;

  const SearchFieldWidget({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: "Search services...",
          prefixIcon: Icon(Icons.search, color: Colors.teal),
          filled: true,
          fillColor: AppColors.border,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
