import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile/service_provider_profile_controller.dart';
import '../models/profile/user_profile_model.dart';

import '../widgets/bottom_nav_bar.dart';
import '../../theme/app_colors.dart';
import '../views/user_management/login.dart';
import '../views/user_management/reset_password.dart';

class ServiceProviderProfileForm extends StatelessWidget {
  final UserProfile profile;
  final ServiceProviderProfileController controller;
  final VoidCallback refresh;

  const ServiceProviderProfileForm({
    super.key,
    required this.profile,
    required this.controller,
    required this.refresh,
  });

  void _editField(BuildContext context, String fieldKey, String title, String value) {
    final textController = TextEditingController(text: value);
    String? errorText;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: title, errorText: errorText),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final newValue = textController.text.trim();
                if (newValue.isEmpty) {
                  setState(() => errorText = "$fieldKey cannot be empty");
                } else {
                  await controller.updateProfileField(fieldKey, newValue);
                  refresh();
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      await controller.updateProfileImage(bytes);
      refresh();
    }
  }

  void _confirmAction(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Provider Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: profile.profileImage != null
                        ? MemoryImage(profile.profileImage!)
                        : const AssetImage('assets/images/person1.jpg') as ImageProvider,
                  ),
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _pickImage(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('${profile.firstName} ${profile.lastName}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildProfileTile(context, Icons.person, "First Name", profile.firstName, "firstName"),
            _buildProfileTile(context, Icons.person_outline, "Last Name", profile.lastName, "lastName"),
            _buildProfileTile(context, Icons.phone, "Phone Number", profile.phoneNumber, "phone"),
            _buildProfileTile(context, Icons.location_on, "Location", profile.location, "location", editable: true),
            const SizedBox(height: 30),
            _buildSimpleTile(
              icon: Icons.lock_reset,
              text: "Change Password",
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ResetPasswordScreen(contact: ''))),
            ),
            _buildSimpleTile(
              icon: Icons.delete_forever,
              text: "Delete Account",
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _confirmAction(context, "Delete Account",
                  "Are you sure you want to delete your account?", () async {
                final password = await _promptPassword(context);
                if (password != null) {
                  await controller.deleteAccount(password);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }),
            ),
            _buildSimpleTile(
              icon: Icons.logout,
              text: "Log Out",
              onTap: () => _confirmAction(
                context,
                "Log Out",
                "Are you sure you want to log out?",
                () async {
                  await controller.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProfileTile(BuildContext context, IconData icon, String title, String value,
      String fieldKey, {bool editable = true}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Container(
        width: 160,
        child: InkWell(
          onTap: editable
              ? () => _editField(context, fieldKey, title, value)
              : null,
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.text,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<String?> _promptPassword(BuildContext context) async {
    String password = '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Re-authenticate"),
          content: TextField(
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Enter your password'),
            onChanged: (value) => password = value,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () => Navigator.of(context).pop(password),
            ),
          ],
        );
      },
    );
  }
}
