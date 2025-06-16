
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controllers/booking/client_controller.dart';
import '../../models/booking/client_model.dart';
import '../../widgets/bottom_nav_bar.dart';

class EnhancedProviderClientsTableView extends StatelessWidget {
  const EnhancedProviderClientsTableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientController()..initialize(),
      child: const _ClientViewContent(),
    );
  }
}

class _ClientViewContent extends StatelessWidget {
  const _ClientViewContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Clients',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(controller.isTableView ? Icons.view_list : Icons.grid_view),
                tooltip: controller.isTableView ? 'Switch to Card View' : 'Switch to Table View',
                onPressed: controller.toggleView,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: controller.loadClients,
              ),
            ],
          ),
          bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
                  ? Center(
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : controller.clients.isEmpty
                      ? _buildEmptyState(controller)
                      : Column(
                          children: [
                            _buildSearchAndCounter(controller),
                            Expanded(
                              child: controller.isTableView
                                  ? _ClientsTable()
                                  : _ClientsCardList(),
                            ),
                          ],
                        ),
        );
      },
    );
  }

  Widget _buildEmptyState(ClientController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Clients Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any confirmed bookings',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            onPressed: controller.loadClients,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndCounter(ClientController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${controller.filteredClients.length} client(s)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClientController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 600,
            showCheckboxColumn: false,
            columns: [
              DataColumn2(
                label: const Text('CLIENT', style: TextStyle(fontWeight: FontWeight.bold)),
                size: ColumnSize.L,
                onSort: (columnIndex, ascending) {
                  controller.sortClients('name', ascending);
                },
              ),
              DataColumn2(
                label: const Text('SERVICE', style: TextStyle(fontWeight: FontWeight.bold)),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  controller.sortClients('service', ascending);
                },
              ),
              DataColumn2(
                label: const Text('DATE/TIME', style: TextStyle(fontWeight: FontWeight.bold)),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  controller.sortClients('date', ascending);
                },
              ),
              DataColumn2(
                label: const Text('LOCATION', style: TextStyle(fontWeight: FontWeight.bold)),
                size: ColumnSize.L,
              ),
              DataColumn2(
                label: const Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                size: ColumnSize.M,
              ),
            ],
            rows: controller.filteredClients.map<DataRow>((client) {
              return DataRow(
                cells: [
                  DataCell(
                    _buildClientCell(client),
                    onTap: () => _showClientDetailsDialog(context, client, controller),
                  ),
                  DataCell(
                    Text(client.service ?? 'N/A'),
                    onTap: () => _showClientDetailsDialog(context, client, controller),
                  ),
                  DataCell(
                    _buildDateTimeCell(client),
                    onTap: () => _showClientDetailsDialog(context, client, controller),
                  ),
                  DataCell(
                    Text(
                      client.location ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _showClientDetailsDialog(context, client, controller),
                  ),
                  DataCell(_buildActionButtons(context, client, controller)),
                ],
                onSelectChanged: (selected) {
                  if (selected == true) {
                    _showClientDetailsDialog(context, client, controller);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildClientCell(ClientModel client) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: client.profileImage != null 
              ? NetworkImage(client.profileImage!) 
              : null,
          child: client.profileImage == null 
              ? Text((client.name ?? 'U')[0].toUpperCase()) 
              : null,
          radius: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                client.name ?? 'Unknown Client',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (client.email != null && client.email != 'N/A')
                Text(
                  client.email!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeCell(ClientModel client) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(client.date ?? 'N/A'),
        Text(
          client.time ?? 'N/A',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ClientModel client, ClientController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Delete Booking',
          onPressed: () => controller.deleteBooking(client.id, client.name ?? 'Client', context),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          tooltip: 'Mark Complete',
          onPressed: () => controller.completeBooking(client.id, client.name ?? 'Client', context),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _showClientDetailsDialog(BuildContext context, ClientModel client, ClientController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client.name ?? 'Client Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (client.profileImage != null)
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(client.profileImage!),
                    radius: 40,
                  ),
                ),
              if (client.profileImage == null)
                Center(
                  child: CircleAvatar(
                    child: Text((client.name ?? 'U')[0].toUpperCase()),
                    radius: 40,
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Full Name', client.name ?? 'N/A'),
              _buildDetailRow('Email', client.email ?? 'N/A'),
              _buildDetailRow('Phone', client.phone ?? 'N/A'),
              _buildDetailRow('Service', client.service ?? 'N/A'),
              _buildDetailRow('Date', client.date ?? 'N/A'),
              _buildDetailRow('Time', client.time ?? 'N/A'),
              _buildDetailRow('Location', client.location ?? 'N/A'),
              _buildDetailRow('Booked on', controller.formatDate(client.timestamp)),
              if (client.notes != null && client.notes!.isNotEmpty)
                _buildDetailRow('Notes', client.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              controller.deleteBooking(client.id, client.name ?? 'Client', context);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete'),
            onPressed: () {
              Navigator.pop(context);
              controller.completeBooking(client.id, client.name ?? 'Client', context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ClientsCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClientController>(
      builder: (context, controller, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredClients.length,
          itemBuilder: (context, index) {
            final client = controller.filteredClients[index];
            return _buildClientCard(client, controller, context);
          },
        );
      },
    );
  }

  Widget _buildClientCard(ClientModel client, ClientController controller, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: client.profileImage != null 
                      ? NetworkImage(client.profileImage!) 
                      : null,
                  child: client.profileImage == null 
                      ? Text((client.name ?? 'U')[0].toUpperCase()) 
                      : null,
                  radius: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name ?? 'Unknown Client',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (client.email != null && client.email != 'N/A')
                        Text(
                          client.email!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      if (client.phone != null && client.phone != 'N/A')
                        Text(
                          client.phone!,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    client.status ?? 'Active',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Service', client.service ?? 'N/A'),
            _buildInfoRow('Date', client.date ?? 'N/A'),
            _buildInfoRow('Time', client.time ?? 'N/A'),
            _buildInfoRow('Location', client.location ?? 'N/A'),
            _buildInfoRow('Booked on', controller.formatDate(client.timestamp)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () => controller.deleteBooking(client.id, client.name ?? 'Client', context),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete'),
                  onPressed: () => controller.completeBooking(client.id, client.name ?? 'Client', context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
