import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_management/reset_password_model.dart';
import '../../views/user_management/login.dart';

class ResetPasswordController {
  final ResetPasswordModel model;

  ResetPasswordController(this.model);

  Future<void> resetPassword({
    required BuildContext context,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!model.isValidPassword(newPassword)) {
      _showDialog(context, "Invalid Password", "Password must meet security requirements.");
      return;
    }

    if (!model.passwordsMatch(newPassword, confirmPassword)) {
      _showDialog(context, "Mismatch", "Passwords do not match.");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _showDialog(
          context,
          "Success",
          "Your password has been updated.",
          onConfirm: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'too-many-requests'
          ? "Too many attempts. Try again later."
          : "An error occurred.";
      _showDialog(context, "Error", message);
    }
  }

  void _showDialog(BuildContext context, String title, String content, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
          ),
        ],
      ),
    );
  }
}
