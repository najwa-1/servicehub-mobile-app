import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_management/forgot_password_controller.dart';
import '../../forms/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forgot Password"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ForgotPasswordForm(),
        ),
      ),
    );
  }
}
