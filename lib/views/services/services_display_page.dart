import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../controllers/service/services_display_controller.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/rating_and_service/category_dropdown_widget.dart';
import '../../widgets/rating_and_service/search_field_widget.dart';
import '../../widgets/rating_and_service/service_card_widget.dart';
import 'services_provider_page.dart';

class ServicesDisplayPage extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  ServicesDisplayPage({required this.services});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServicesDisplayController(services),
      child: Consumer<ServicesDisplayController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Display Services",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              backgroundColor: AppColors.primary,
              actions: [
                CategoryDropdownWidget(
                  selectedCategory: controller.selectedCategory,
                  categories: controller.getCategories(),
                  onChanged: controller.onCategoryChanged,
                ),
              ],
            ),
            body: Column(
              children: [
                SearchFieldWidget(
                  controller: controller.searchController,
                  onChanged: (_) => controller.storeSearchQuery(
                    controller.searchController.text,
                  ),
                  onSubmitted: controller.storeSearchQuery,
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: controller.filteredServices.length,
                    itemBuilder: (_, index) {
                      final service = controller.filteredServices[index];
                      return ServiceCardWidget(
                        service: service,
                        role: controller.userRole,
                        onDelete: () => controller.deleteService(service),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'provider',
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person),
              onPressed: () async {
                try {
                  final servicesList = await controller.fetchAllServices();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServicesProviderPage(services: servicesList),
                    ),
                  );
                } catch (e) {
                  print('Error fetching services: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An error occurred while loading services.')),
                  );
                }
              },
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 0),
          );
        },
      ),
    );
  }
}
