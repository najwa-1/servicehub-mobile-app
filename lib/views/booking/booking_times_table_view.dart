import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/booking/booking_controller.dart';
import '../../models/booking/booking_model.dart';
import '../../widgets/bottom_nav_bar.dart';


class BookingTimesTableView extends StatefulWidget {
  final Map<String, String> bookingData;
  const BookingTimesTableView({
    Key? key,
    required this.bookingData,
  }) : super(key: key);

  @override
  State<BookingTimesTableView> createState() => _BookingTimesTableViewState();
}

class _BookingTimesTableViewState extends State<BookingTimesTableView> {
  late BookingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BookingController();
    _controller.setCurrentBookingId(widget.bookingData['id'] ?? '');
    _controller.fetchAllBookings();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<BookingController>(
        builder: (context, controller, child) {
          return WillPopScope(
            onWillPop: () async {
              if (controller.isLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please wait, data is loading...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return false;
              }
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'All Bookings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.teal,
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (!controller.isLoading) {
                      Navigator.pop(context);
                    }
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: controller.isLoading ? null : controller.refreshData,
                    tooltip: 'Refresh bookings',
                  ),
                ],
              ),
              body: controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    )
                  : controller.hasError
                      ? _buildErrorWidget(controller)
                      : _buildBookingsContent(controller),
              bottomNavigationBar: const BottomNavBar(currentIndex: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BookingController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Bookings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              controller.retryFetch();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(controller.errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsContent(BookingController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'All Bookings (${controller.bookingsCount})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: controller.isEmpty()
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No bookings found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildBookingsTable(controller.allBookings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsTable(List<BookingModel> bookings) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                color: booking.isCurrentBooking ? Colors.teal.shade50 : null,
                child: ExpansionTile(
                  leading: booking.isCurrentBooking 
                    ? Icon(Icons.star, color: Colors.teal, size: 20)
                    : null,
                  title: Text(
                    booking.name.isNotEmpty ? booking.name : 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: booking.isCurrentBooking ? Colors.teal.shade700 : null,
                    ),
                  ),
                  subtitle: Text(
                    '${booking.service.isNotEmpty ? booking.service : 'Unknown Service'} - ${booking.date.isNotEmpty ? booking.date : 'Unknown Date'}',
                    style: TextStyle(
                      color: booking.isCurrentBooking ? Colors.teal.shade600 : null,
                    ),
                  ),
                  children: [
                    Container(
                      color: booking.isCurrentBooking ? Colors.teal.shade100 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (booking.isCurrentBooking)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Your Booking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            _buildInfoRow('Service', booking.service.isNotEmpty ? booking.service : 'N/A'),
                            _buildInfoRow('Provider', booking.provider.isNotEmpty ? booking.provider : 'N/A'),
                            _buildInfoRow('Location', booking.location.isNotEmpty ? booking.location : 'N/A'),
                            _buildInfoRow('Date', booking.date.isNotEmpty ? booking.date : 'N/A'),
                            _buildInfoRow('Time', booking.time.isNotEmpty ? booking.time : 'N/A'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            dataRowHeight: 60,
            headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.teal.shade50,
            ),
            columns: const [
              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Provider', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: bookings.map((booking) {
              return DataRow(
                color: MaterialStateColor.resolveWith(
                  (states) => booking.isCurrentBooking ? Colors.teal.shade50 : Colors.transparent,
                ),
                cells: [
                  DataCell(
                    Row(
                      children: [
                        if (booking.isCurrentBooking)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.star, color: Colors.teal, size: 16),
                          ),
                        Expanded(
                          child: Text(
                            booking.name.isNotEmpty ? booking.name : 'N/A',
                            style: TextStyle(
                              fontWeight: booking.isCurrentBooking ? FontWeight.bold : FontWeight.normal,
                              color: booking.isCurrentBooking ? Colors.teal.shade700 : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(booking.service.isNotEmpty ? booking.service : 'N/A')),
                  DataCell(Text(booking.provider.isNotEmpty ? booking.provider : 'N/A')),
                  DataCell(Text(booking.location.isNotEmpty ? booking.location : 'N/A')),
                  DataCell(Text(booking.date.isNotEmpty ? booking.date : 'N/A')),
                  DataCell(Text(booking.time.isNotEmpty ? booking.time : 'N/A')),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
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