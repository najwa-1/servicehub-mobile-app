import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_management/reset_method_model.dart';
import '../../views/user_management/login.dart';
import '../../views/user_management/varify.dart';

class ForgotPasswordController extends ChangeNotifier {
  final contactController = TextEditingController();
  ResetMethod method = ResetMethod.email;
  bool isButtonEnabled = false;

  void toggleMethod(int index) {
    method = ResetMethod.values[index];
    contactController.clear();
    isButtonEnabled = false;
    notifyListeners();
  }

  void updateButtonState() {
    isButtonEnabled = contactController.text.trim().isNotEmpty;
    notifyListeners();
  }

  Future<void> sendResetCode(BuildContext context) async {
    final contact = contactController.text.trim();
    final isValid = ResetData()
      ..contact = contact
      ..method = method;

    if (!isValid.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${method == ResetMethod.email ? "email" : "phone number"}'),
        ),
      );
      return;
    }

    if (method == ResetMethod.email) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: contact);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: contact,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Verification failed: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerifyCodeScreen(
                  contact: contact,
                  method: 'sms',
                  verificationId: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  void disposeController() {
    contactController.dispose();
  }
}
