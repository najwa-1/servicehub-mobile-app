import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/booking/booking_form_controller.dart';
import '../../widgets/booking_widgets/booking_form_fields.dart';
import '../../widgets/bottom_nav_bar.dart';


class BookingFormView extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingFormView({super.key, required this.service});

  @override
  State<BookingFormView> createState() => _BookingFormViewState();
}

class _BookingFormViewState extends State<BookingFormView> {
  late BookingFormController controller;

  @override
  void initState() {
    super.initState();
    controller = BookingFormController();
    controller.initializeService(widget.service);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _showBookingConfirmation() async {
    final confirmationData = controller.getConfirmationData();
    
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          title: Column(
            children: [
              Icon(
                Icons.calendar_month,
                size: 48,
                color: Colors.teal,
              ),
              const SizedBox(height: 12),
              const Text(
                'Confirm Booking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please review your booking details:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                _buildSimpleDetailRow('Service', confirmationData['serviceName']!),
                _buildSimpleDetailRow('Provider', confirmationData['serviceProvider']!),
                _buildSimpleDetailRow('Name', confirmationData['name']!),
                _buildSimpleDetailRow('Location', confirmationData['location']!),
                _buildSimpleDetailRow('Date', confirmationData['date']!),
                _buildSimpleDetailRow('Time', confirmationData['time']!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _handleBookingSubmission();
    }
  }

  Widget _buildSimpleDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBookingSubmission() async {
    final success = await controller.submitBooking();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent! Awaiting provider approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleBookingPress() {
    _showBookingConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Booking',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<BookingFormController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The service: ${controller.serviceName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The service Provider: ${controller.serviceProvider}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    
                    LabeledTextField(
                      label: 'Name',
                      hintText: 'Enter your name',
                      controller: controller.nameController,
                    ),
                    
                    LabeledTextField(
                      label: 'Phone Number',
                      hintText: 'Enter your phone number',
                      controller: controller.phoneController,
                    ),
                    
                    LabeledTextField(
                      label: 'Location',
                      hintText: 'Enter your location',
                      controller: controller.locationController,
                    ),
                    
                    LabeledTextField(
                      label: 'Time',
                      hintText: 'Enter the time you want',
                      controller: controller.timeController,
                      readOnly: true,
                      onTap: () {
                        controller.selectTime(context);
                      },
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () {
                          controller.selectTime(context);
                        },
                      ),
                    ),
                    
                    LabeledTextField(
                      label: 'Date',
                      hintText: 'Enter the date you want',
                      controller: controller.dateController,
                      readOnly: true,
                      onTap: () {
                        controller.selectDate(context);
                      },
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          controller.selectDate(context);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (controller.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: controller.isFormValid ? _handleBookingPress : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}