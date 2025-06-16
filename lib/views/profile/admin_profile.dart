import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/profile/admin_controller.dart';
import '../../models/profile/customer_profile_model.dart';
import '../../forms/admin_profile_form.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../user_management/create_account.dart';
import '../user_management/reset_password.dart';


class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfilePage> {
  final AdminProfileController _controller = AdminProfileController();
  CustomerProfile? _admin;
  Uint8List? _profileImageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

Future<void> _loadAdminProfile() async {
  final profile = await _controller.fetchAdminProfile();
  if (mounted) {
    setState(() {
      _admin = profile;
      if (profile?.profileImageBase64 != null) {
        try {
          _profileImageBytes = base64Decode(profile!.profileImageBase64!);
        } catch (e) {
          debugPrint("Failed to decode profile image: $e");
          _profileImageBytes = null;
        }
      } else {
        _profileImageBytes = null;
      }
      _isLoading = false;
    });
  }
}


  Future<void> _showEditDialog(String title, String field, String currentValue) async {
    String updatedValue = currentValue;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update $title"),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: currentValue),
          onChanged: (value) => updatedValue = value,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, updatedValue), child: const Text("Save")),
        ],
      ),
    );

    if (result != null && result != currentValue) {
      await _controller.updateField(field, result);
      _loadAdminProfile();
    }
  }

  void _pickProfileImage() async {
    final pickedBytes = await _controller.updateProfileImage(ImageSource.gallery);
    if (pickedBytes != null) {
      setState(() => _profileImageBytes = pickedBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _admin == null
              ? const Center(child: Text("Profile not found."))
              : ListView(
  padding: const EdgeInsets.all(20),
  children: [
    buildProfilePicture(
      imageBytes: _profileImageBytes,
      onEdit: _pickProfileImage,
    ),
    const SizedBox(height: 24),

    buildProfileTile(
      icon: Icons.person,
      title: 'First Name',
      value: _admin!.firstName,
      onTap: () => _showEditDialog('First Name', 'firstName', _admin!.firstName),
    ),
    buildProfileTile(
      icon: Icons.person_outline,
      title: 'Last Name',
      value: _admin!.lastName,
      onTap: () => _showEditDialog('Last Name', 'lastName', _admin!.lastName),
    ),
    buildProfileTile(
      icon: Icons.phone,
      title: 'Phone',
      value: _admin!.phone,
      onTap: () => _showEditDialog('Phone', 'phone', _admin!.phone),
    ),
  buildProfileTile(
  icon: Icons.location_on,
  title: 'Location',
  value: _admin!.location,
  onTap: () => _showEditDialog('Location', 'location', _admin!.location),
),

           const SizedBox(height: 24),
                    buildActionTile(
                      icon: Icons.person_add,
                      title: 'Create Admin Account',
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) =>  CreateAccountScreen(role: 'Admin',),
                      )),
                    ),

    const SizedBox(height: 24),
    buildActionTile(
      icon: Icons.lock_reset,
      title: 'Reset Password',
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(contact: '',),
        ));
      },
    ),
    buildActionTile(
      icon: Icons.delete_forever,
      title: 'Delete Account',
      onTap: () => _controller.deleteAccount(context),
      iconColor: Colors.red,
      textColor: Colors.red,
    ),
    buildActionTile(
      icon: Icons.logout,
      title: 'Log Out',
      onTap: () => _controller.logout(context),
    ),
  ],
),
     bottomNavigationBar: const BottomNavBar(currentIndex: 3),

    );
  }
}
