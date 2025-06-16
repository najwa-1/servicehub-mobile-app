import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final bool showError;
  final String errorText;
  final VoidCallback? toggleObscure;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  const LoginTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.showError = false,
    this.errorText = '',
    this.toggleObscure,
    this.onChanged,
    this.keyboardType = TextInputType.emailAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPasswordField = toggleObscure != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.light),
            border: const OutlineInputBorder(),
            errorText: showError ? errorText : null,
            suffixIcon: isPasswordField
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.light,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}