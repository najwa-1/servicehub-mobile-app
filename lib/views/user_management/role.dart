import 'package:flutter/material.dart';
import '../../controllers/user_management/role_selection_controller.dart';
import '../../forms/role_selection_form.dart';
import '../../theme/app_colors.dart';


class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RoleSelectionController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: RoleSelectionForm(controller: controller),
        ),
      ),
    );
  }
}
