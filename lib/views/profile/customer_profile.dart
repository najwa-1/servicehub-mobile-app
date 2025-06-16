import 'dart:typed_data';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/profile/customer_profile_controller.dart';
import '../../models/profile/customer_profile_model.dart';
import '../../forms/customer_profile_form.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../user_management/reset_password.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({Key? key}) : super(key: key);

  @override
  State<CustomerProfilePage> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfilePage> {
  final CustomerProfileController _controller = CustomerProfileController();

  CustomerProfile? _customer;
  Uint8List? _profileImageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    final profile = await _controller.fetchCustomerProfile();
    if (mounted) {
      setState(() {
        _customer = profile;
        if (profile?.profileImageBase64 != null) {
          try {
            _profileImageBytes = base64Decode(profile!.profileImageBase64!);
          } catch (e) {
            _profileImageBytes = null;
          }
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
      _loadCustomerProfile();
    }
  }

  void _pickProfileImage() async {
    final base64String = await _controller.updateProfileImage(ImageSource.gallery);
    if (base64String != null) {
      setState(() {
        try {
          _profileImageBytes = base64Decode(base64String);
        } catch (e) {
          _profileImageBytes = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Profile"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customer == null
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
                      value: _customer!.firstName,
                      onTap: () => _showEditDialog('First Name', 'firstName', _customer!.firstName),
                    ),
                    buildProfileTile(
                      icon: Icons.person_outline,
                      title: 'Last Name',
                      value: _customer!.lastName,
                      onTap: () => _showEditDialog('Last Name', 'lastName', _customer!.lastName),
                    ),
                    buildProfileTile(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: _customer!.phone,
                      onTap: () => _showEditDialog('Phone', 'phone', _customer!.phone),
                    ),
                    buildProfileTile(
                      icon: Icons.location_on,
                      title: 'Location',
                      value: _customer!.location,
                      onTap: () => _showEditDialog('Location', 'location', _customer!.location),
                    ),
                    const SizedBox(height: 24),
                    buildActionTile(
                      icon: Icons.lock_reset,
                      title: 'Reset Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordScreen(contact: ''),
                          ),
                        );
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

  Widget buildProfilePicture({
    required Uint8List? imageBytes,
    required VoidCallback onEdit,
  }) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
            child: imageBytes == null ? const Icon(Icons.person, size: 60) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: Icon(Icons.edit, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit),
      onTap: onTap,
    );
  }

  Widget buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
