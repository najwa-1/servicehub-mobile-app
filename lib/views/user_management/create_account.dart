import 'package:flutter/material.dart';
import '../../forms/create_account_form.dart';

class CreateAccountScreen extends StatelessWidget {
  final String role;
  const CreateAccountScreen({required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children:  [
            SizedBox(height: 120),
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            CreateAccountForm(role: role),
          ],
        ),
      ),
    );
  }
}
