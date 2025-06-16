import 'package:flutter/material.dart';

import '../../controllers/user_management/verify_code_controller.dart';
import '../../models/user_management/verify_code_model.dart';
import '../../forms/verify_code_form.dart';
import 'reset_password.dart';


class VerifyCodeScreen extends StatefulWidget {
  final String contact;
  final String method;
  final String verificationId;

  const VerifyCodeScreen({
    required this.contact,
    required this.method,
    required this.verificationId,
    super.key,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  late final VerifyCodeModel _model;
  late final VerifyCodeController _controller;

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _model = VerifyCodeModel();
    _controller = VerifyCodeController(_model);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    _controller.updateDigit(index, value);

    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _verifyCode() {
    _controller.verifyCode(
      verificationId: widget.verificationId,
      onSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(contact: widget.contact),
          ),
        );
      },
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $message')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify ${widget.method.toUpperCase()}"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100),
              Text(
                'Enter the code sent to your ${widget.method}:',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                widget.contact,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              VerifyCodeForm(
                controllers: _controllers,
                focusNodes: _focusNodes,
                onDigitEntered: _onDigitEntered,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _controller.isCodeComplete ? _verifyCode : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Verify', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
