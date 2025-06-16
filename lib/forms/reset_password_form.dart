import 'package:flutter/material.dart';

class ResetPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final VoidCallback toggleNewPasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;
  final VoidCallback onSubmit;

  const ResetPasswordForm({
    super.key,
    required this.formKey,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.obscureNewPassword,
    required this.obscureConfirmPassword,
    required this.toggleNewPasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 30),
          TextFormField(
            controller: newPasswordController,
            obscureText: obscureNewPassword,
            decoration: InputDecoration(
              labelText: "New Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleNewPasswordVisibility,
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter a new password." : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: toggleConfirmPasswordVisibility,
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Confirm your password." : null,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text("Reset Password"),
          ),
        ],
      ),
    );
  }
}
