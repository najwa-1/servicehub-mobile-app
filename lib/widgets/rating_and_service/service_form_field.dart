import 'package:flutter/material.dart';

class ServiceFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isNumber;
  final int maxLines;
  final VoidCallback onChanged;

  const ServiceFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.isNumber = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (_) => onChanged(),
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textCapitalization:
          isNumber ? TextCapitalization.none : TextCapitalization.sentences, 
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }
}
