import 'package:flutter/material.dart';
import '../../models/booking/booking_model.dart';

class BookingDetailsCard extends StatelessWidget {
  final Map<String, String> bookingData;
  final String title;

  const BookingDetailsCard({
    Key? key,
    required this.bookingData,
    this.title = 'Booking Information',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', bookingData['name'] ?? ''),
            _buildInfoRow('Service', bookingData['service'] ?? ''),
            _buildInfoRow('Provider', bookingData['provider'] ?? ''),
            _buildInfoRow('Location', bookingData['location'] ?? ''),
            _buildInfoRow('Date', bookingData['date'] ?? ''),
            _buildInfoRow('Time', bookingData['time'] ?? ''),
          ],
        ),
      ),
    );
  }

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          softWrap: true,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}

}