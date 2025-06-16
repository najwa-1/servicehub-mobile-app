import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/service/services_provider_controller.dart';
import '../../theme/app_colors.dart';

class ServicesProviderPage extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  ServicesProviderPage({required this.services});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServicesProviderController(services),
      child: Consumer<ServicesProviderController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Provider Services"),
              backgroundColor: AppColors.primary,
            ),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: "Search by provider name...",
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.border,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: controller.filteredServices.length,
                    itemBuilder: (_, index) {
                      final service = controller.filteredServices[index];
                      final userId = service['userId'] as String?;
                      final providerName = service['user'] ?? 'Unknown';
                      final imageBytes = userId != null
                          ? controller.profileImagesCache[userId]
                          : null;

                      return Stack(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.vertical(top: Radius.circular(12)),
                                    child: imageBytes != null
                                        ? Image.memory(imageBytes,
                                            fit: BoxFit.cover, width: double.infinity)
                                        : Image.asset(
                                            'assets/images/person1.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    providerName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (controller.userRole == 'Admin')
                            Positioned(
                              top: -1,
                              right: 8,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text('Are you sure you want to delete this Provider?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text('Cancel')),
                                        TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final success = await controller.deleteService(context, service);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(success
                                          ? 'Provider deleted'
                                          : 'Failed to delete provider')),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
