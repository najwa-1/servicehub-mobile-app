import 'package:flutter/material.dart';

import '../../repository/service_repository.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/rating_and_service/add_service_card_widget.dart';
import '../../widgets/rating_and_service/search_bar_widget.dart';
import '../../widgets/rating_and_service/service_card.dart';
import 'add_service_page.dart';

import 'services_display_page.dart';

import 'services_provider_page.dart';
import 'update_service.dart';



class ServicesPage extends StatefulWidget {
  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ServiceRepository _serviceRepository = ServiceRepository();

  List<Map<String, dynamic>> services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(() => setState(() {}));
  }

  void _loadServices() {
    _serviceRepository.fetchServices().then((loadedServices) {
      setState(() {
        services = loadedServices;
      });
    });
  }

  void _deleteService(Map<String, dynamic> service) {
    _serviceRepository.deleteService(service['id']).then((_) {
      setState(() {
        services.removeWhere((s) => s['id'] == service['id']);
      });
    });
  }

  void _updateService(Map<String, dynamic> service) async {
    final updatedService = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateService(service: service),
      ),
    );

    if (updatedService != null) {
      await _serviceRepository.updateService(service['id'], updatedService);
      int index = services.indexWhere((s) => s['id'] == service['id']);
      if (index != -1) {
        setState(() {
          services[index] = {...updatedService, 'id': service['id']};
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = services
        .where((s) => s['name'].toString().toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[600],
        elevation: 4,
        title: Text("ServiceHub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchBarWidget(controller: _searchController),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 600;

                if (isWideScreen) {
                  return Row(
                    children: [
                      Container(
                        width: 300,
                        padding: EdgeInsets.all(12),
                        child: AddServiceCard(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddServicePage()),
                            );
                            if (result != null && result is String) {
                              final newService = await _serviceRepository.getServiceById(result);
                              if (newService != null) {
                                setState(() {
                                  services.add(newService);
                                });
                              }
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final service = filtered[index];
                            return ServiceCard(
                              service: service,
                              onEdit: () => _updateService(service),
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Delete Service"),
                                    content: Text("Are you sure you want to delete this service?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteService(service);
                                        },
                                        child: Text("Delete", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return AddServiceCard(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AddServicePage()),
                            );
                            if (result != null && result is String) {
                              final newService = await _serviceRepository.getServiceById(result);
                              if (newService != null) {
                                setState(() {
                                  services.add(newService);
                                });
                              }
                            }
                          },
                        );
                      }

                      final service = filtered[index - 1];
                      return ServiceCard(
                        service: service,
                        onEdit: () => _updateService(service),
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Delete Service"),
                              content: Text("Are you sure you want to delete this service?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteService(service);
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'provider',
            backgroundColor: Colors.teal,
            child: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServicesProviderPage(services: services),
                ),
              );
            },
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'display',
            backgroundColor: Colors.teal[700],
            child: Icon(Icons.grid_view),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServicesDisplayPage(services: services),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
} 