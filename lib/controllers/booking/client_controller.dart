import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/booking/client_model.dart';
import '../../services/client_service.dart';

class ClientController extends ChangeNotifier {
  final ClientService _clientService = ClientService();
  
  List<ClientModel> _clients = [];
  List<ClientModel> _filteredClients = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTableView = true;
  String _searchQuery = '';
  String _sortColumn = 'timestamp';
  bool _sortAscending = false;

  List<ClientModel> get clients => _clients;
  List<ClientModel> get filteredClients => _filteredClients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTableView => _isTableView;
  String get searchQuery => _searchQuery;
  String get sortColumn => _sortColumn;
  bool get sortAscending => _sortAscending;

  Future<void> initialize() async {
    await loadClients();
  }

  Future<void> loadClients() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _clients = await _clientService.loadClients();
      _sortAndFilterClients();
      _setLoading(false);
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
    }
  }

  Future<void> completeBooking(String bookingId, String clientName, BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Complete Booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to mark $clientName\'s booking as complete?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The client will be notified that the service has been completed.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Mark Complete', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _clientService.completeBooking(bookingId);
      await loadClients();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$clientName\'s booking has been marked as complete. Client has been notified.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteBooking(String bookingId, String clientName, BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Remove Client',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to remove $clientName from your client list?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The client will be notified about the cancellation.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Remove Client', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _clientService.deleteBooking(bookingId);
      await loadClients();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$clientName has been removed and notified about the cancellation.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void toggleView() {
    _isTableView = !_isTableView;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _sortAndFilterClients();
    notifyListeners();
  }

  void sortClients(String column, bool ascending) {
    _sortColumn = column;
    _sortAscending = ascending;
    _sortAndFilterClients();
    notifyListeners();
  }

  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } 
    
    return date.toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setErrorMessage(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _sortAndFilterClients() {
    final sortedClients = _clientService.sortClients(_clients, _sortColumn, _sortAscending);
    
    _filteredClients = _clientService.filterClients(sortedClients, _searchQuery);
  }

  @override
  void dispose() {
    super.dispose();
  }
}