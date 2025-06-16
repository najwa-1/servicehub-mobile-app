
import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const LabeledTextField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
          onTap: onTap,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Colors.grey,
          side: BorderSide(color: textColor ?? Colors.grey),
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled 
              ? (backgroundColor ?? Colors.teal) 
              : Colors.grey,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      );
    }
  }
}