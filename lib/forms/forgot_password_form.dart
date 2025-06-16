import 'package:flutter/material.dart';
import '../controllers/user_management/forgot_password_controller.dart';
import '../models/user_management/reset_method_model.dart';
import 'package:provider/provider.dart';

import '../views/user_management/login.dart';

class ForgotPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ForgotPasswordController>(context);
    final method = controller.method;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 120),
        const Text(
          'Forgot your password?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Enter your ${method == ResetMethod.email ? 'email address' : 'phone number'} below and we\'ll send you a code to reset your password.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const Center(
          child: Text(
            'Choose how to receive the reset code:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ToggleButtons(
            isSelected: [
              controller.method == ResetMethod.email,
              controller.method == ResetMethod.sms
            ],
            onPressed: controller.toggleMethod,
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.teal,
            color: Colors.black,
            constraints: const BoxConstraints(minHeight: 45, minWidth: 120),
            children: const [Text("Email"), Text("SMS")],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          key: ValueKey(method),
          controller: controller.contactController,
          onChanged: (_) => controller.updateButtonState(),
          keyboardType: method == ResetMethod.email
              ? TextInputType.emailAddress
              : TextInputType.phone,
          decoration: InputDecoration(
            labelText: method == ResetMethod.email ? "Email" : "Phone Number",
            hintText: method == ResetMethod.email
                ? "Enter your email"
                : "Enter your phone number",
            border: const OutlineInputBorder(),
            hintStyle: const TextStyle(color: Colors.blueGrey),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: controller.isButtonEnabled
              ? () => controller.sendResetCode(context)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Send Code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
