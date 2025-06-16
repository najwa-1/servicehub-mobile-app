import 'package:flutter/material.dart';

import '../../views/user_management/create_account.dart';

class RoleSelectionController {
  void navigateToCreateAccount(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAccountScreen(role: role),
      ),
    );
  }
}
