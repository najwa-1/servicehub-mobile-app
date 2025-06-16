import 'package:flutter/material.dart';
import '../../controllers/user_management/reset_password_controller.dart';
import '../../models/user_management/reset_password_model.dart';
import '../../forms/reset_password_form.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String contact;
  const ResetPasswordScreen({super.key, required this.contact});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final ResetPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResetPasswordController(ResetPasswordModel());
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _controller.resetPassword(
        context: context,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Set a new password for ${widget.contact}", style: const TextStyle(fontSize: 16)),
            ResetPasswordForm(
              formKey: _formKey,
              newPasswordController: _newPasswordController,
              confirmPasswordController: _confirmPasswordController,
              obscureNewPassword: _obscureNewPassword,
              obscureConfirmPassword: _obscureConfirmPassword,
              toggleNewPasswordVisibility: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
              toggleConfirmPasswordVisibility: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
