import 'package:flutter/material.dart';
import '../../controllers/profile/service_provider_profile_controller.dart';
import '../../models/profile/user_profile_model.dart';
import '../../forms/service_provider_profile_form.dart';

class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({super.key});

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState extends State<ServiceProviderProfile> {
  final _controller = ServiceProviderProfileController();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    _profile = await _controller.loadUserProfile();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ServiceProviderProfileForm(
      profile: _profile!,
      controller: _controller,
      refresh: _loadProfile,
    );
  }
}
