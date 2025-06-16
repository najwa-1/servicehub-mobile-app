import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repository/display_service_repository.dart';
import '../../repository/user_repository.dart';


class ServicesProviderController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final UserRepository _userRepo = UserRepository();
  final ServiceRepository _serviceRepo = ServiceRepository();

  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> filteredServices = [];
  Map<String, Uint8List?> profileImagesCache = {};
  String userRole = 'User';

  ServicesProviderController(List<Map<String, dynamic>> initialServices) {
    allServices = initialServices;
    filteredServices = initialServices;
    searchController.addListener(_handleSearch);
    _loadImages();
    _loadUserRole();
  }

  void _handleSearch() {
    filteredServices = _userRepo.filterServicesByProvider(
      allServices,
      searchController.text,
    );
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('role') ?? 'User';
    notifyListeners();
  }

  Future<void> _loadImages() async {
    final images = await _userRepo.preloadProfileImagesFromServices(allServices);
    profileImagesCache = images;
    notifyListeners();
  }

  Future<bool> deleteService(BuildContext context, Map<String, dynamic> service) async {
    try {
      await _serviceRepo.deleteService(service['id']);
      allServices.removeWhere((s) => s['id'] == service['id']);
      _handleSearch(); 
      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
