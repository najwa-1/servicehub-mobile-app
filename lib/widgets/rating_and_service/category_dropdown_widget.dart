import 'package:flutter/material.dart';

class CategoryDropdownWidget extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String?) onChanged;

  const CategoryDropdownWidget({
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategory,
            dropdownColor: Colors.white,
            style: TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(Icons.filter_list, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
