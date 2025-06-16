import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repository/display_service_repository.dart';

class ServicesDisplayController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final ServiceRepository _serviceRepo = ServiceRepository();

  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> filteredServices = [];
  String selectedCategory = 'All';
  String userRole = 'User';

  ServicesDisplayController(List<Map<String, dynamic>> initialServices) {
    allServices = initialServices;
    filteredServices = initialServices;
    _loadUserRole();
    searchController.addListener(_filterServices);
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('role') ?? 'User';
    notifyListeners();
  }

  List<String> getCategories() {
    final categories = allServices
        .map((s) => s['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  void _filterServices() {
    final query = searchController.text;
    filteredServices = _serviceRepo.filterServices(
      services: allServices,
      query: query,
      selectedCategory: selectedCategory,
    );
    notifyListeners();
  }

  void onCategoryChanged(String? category) {
    if (category == null) return;
    selectedCategory = category;
    _filterServices();
  }

  Future<void> deleteService(Map<String, dynamic> service) async {
    await _serviceRepo.deleteService(service['id']);
    allServices.removeWhere((s) => s['id'] == service['id']);
    _filterServices();
  }

  Future<void> storeSearchQuery(String query) async {
    await _serviceRepo.storeSearchQuery(query);
  }

  Future<List<Map<String, dynamic>>> fetchAllServices() async {
    return await _serviceRepo.fetchAllServices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
