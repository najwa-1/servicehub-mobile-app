import 'package:flutter/material.dart';

class VerifyCodeForm extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(int, String) onDigitEntered;

  const VerifyCodeForm({
    required this.controllers,
    required this.focusNodes,
    required this.onDigitEntered,
    super.key,
  });

  Widget _buildDigitField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => onDigitEntered(index, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, _buildDigitField),
    );
  }
}
