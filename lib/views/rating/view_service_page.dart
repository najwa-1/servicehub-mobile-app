import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../models/rating.dart';
import '../../repository/view_rating_repository.dart';
import '../../widgets/rating_and_service/detail_card_widget.dart';
import '../../widgets/rating_and_service/rating_card_widget.dart';
import '../../widgets/rating_and_service/service_image_widget.dart';
import '../booking/booking_form_view.dart';

import 'rating_page.dart';

class ViewServicePage extends StatefulWidget {
  final Map<String, dynamic> service;

  const ViewServicePage({Key? key, required this.service}) : super(key: key);

  @override
  _ViewServicePageState createState() => _ViewServicePageState();
}

class _ViewServicePageState extends State<ViewServicePage> {
  late Map<String, dynamic> service;
  late viewRatingRepository _ratingRepository;

@override
void initState() {
  super.initState();
  service = Map<String, dynamic>.from(widget.service);
  service['ratings'] = [];

  Future.microtask(() async {
    _ratingRepository = Provider.of<viewRatingRepository>(context, listen: false);
    await _loadRatings();

    
    final status = await fetchBookingStatusByServiceId(service['id'], service['userId']);
    if (status != null) {
      setState(() {
        service['status'] = status;
      });
    }
  });
}

  Future<String?> fetchBookingStatusByServiceId(String serviceId, String providerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('completedBookings')
       .where('service', isEqualTo: service['name']) 
.where('provider', isEqualTo: service['userId'])

          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        
        return data['status'] as String?;
          
      }
      return null;
    } catch (e) {
      print('Error fetching booking status: $e');
      return null;
    }
  }
  Future<void> _loadRatings() async {
    final ratings = await _ratingRepository.loadRatings(service['id']);
    setState(() {
      service['ratings'] = ratings;
    });
  }

  Future<void> _saveRatings() async {
    await _ratingRepository.saveRatings(service['id'], List<Map<String, dynamic>>.from(service['ratings']));
  }

  void _addRating(Rating newRating) {
    setState(() {
      service['ratings'].add(newRating.toMap());
    });
    _saveRatings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your rating has been submitted!')),
    );
  }


  Widget _buildEnhancedRatingButton({required bool isWideScreen}) {
    final bool isCompleted = service['status']?.toString().trim().toLowerCase() == 'completed';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: isCompleted ? [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(
          isCompleted ? Icons.star : Icons.lock,
          size: isWideScreen ? 18 : 16,
          color: isCompleted ? Colors.white : Colors.grey[400],
        ),
        label: Text(
          isCompleted ? 'Add Rating' : 'Rating Locked',
          style: TextStyle(
            fontSize: isWideScreen ? 18 : 16, 
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.white : Colors.grey[400],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCompleted ? Colors.teal : Colors.grey[300],
          foregroundColor: isCompleted ? Colors.white : Colors.grey[400],
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 20 : 8, 
            vertical: isWideScreen ? 12 : 6
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isCompleted ? Colors.white : Colors.grey[400]!, 
              width: isWideScreen ? 2 : 1.5
            ),
          ),
          elevation: isCompleted ? 4 : 1,
        ),
        onPressed: isCompleted ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RatingPage(
                service: service,
                onRatingSubmitted: (ratingMap) {
                  final rating = Rating.fromMap(ratingMap);
                  _addRating(rating);
                },
              ),
            ),
          );
        } : () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Booking Required',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 64, color: Colors.teal),
                    SizedBox(height: 16),
                    Text(
                      'You need to have a completed booking for this service before you can rate it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please book the service first and wait for completion to leave a review.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingFormView(
                            service: {
                              'id': service['id'],
                              'name': service['name'],
                              'user': service['user'],
                              'userId': service['userId'],
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          service['name'] ?? 'Service Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_rate),
            onPressed: () {
              if (service['status']?.toString().trim().toLowerCase() == 'completed') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RatingPage(
                      service: service,
                      onRatingSubmitted: (ratingMap) {
                        final rating = Rating.fromMap(ratingMap);
                        _addRating(rating);
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isWideScreen) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                         const SizedBox(height: 40), 
                         
                        Text(
                          service['name'] ?? '',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'service-image-${service['name']}',
                          child: ClipOval(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: ServiceImageWidget(service: service),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                       
                        _buildEnhancedRatingButton(isWideScreen: true),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text(
                            'Book Now',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingFormView(
                                  service: {
                                    'id': service['id'],
                                    'name': service['name'],
                                    'user': service['user'],
                                    'userId': service['userId'],
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 32),

                  Flexible(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailCardWidget(title: 'Service Provider', content: service['user'] ?? 'N/A'),
                        DetailCardWidget(title: 'Phone Number', content: service['phone'] ?? 'N/A'),
                        DetailCardWidget(title: 'Details', content: service['details'] ?? 'N/A'),
                        DetailCardWidget(title: 'Price', content: '${service['price'] ?? 'N/A'} \$'),
                        const SizedBox(height: 24),

                        if (service['ratings'].isNotEmpty) ...[
                          Text(
                            'Reviews:',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...service['ratings'].map<Widget>((rating) {
                            final r = Rating.fromMap(rating);
                            return RatingCardWidget(rating: r);
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Center(
                    child: Text(
                      service['name'] ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Hero(
                      tag: 'service-image-${service['name']}',
                      child: ClipOval(
                        child: SizedBox(
                          width: 160,
                          height: 160,
                          child: ServiceImageWidget(service: service),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                        minimumSize: const Size(80, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.white, width: 1.5),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingFormView(
                              service: {
                                'id': service['id'],
                                'name': service['name'],
                                'user': service['user'],
                                'userId': service['userId'],
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailCardWidget(title: 'Service Provider', content: service['user'] ?? 'N/A'),
                  DetailCardWidget(title: 'Phone Number', content: service['phone'] ?? 'N/A'),
                  DetailCardWidget(title: 'Details', content: service['details'] ?? 'N/A'),
                  DetailCardWidget(title: 'Price', content: '${service['price'] ?? 'N/A'} \$'),
                  const SizedBox(height: 16),
                 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildEnhancedRatingButton(isWideScreen: false),
                  ),
                  const SizedBox(height: 24),
                  if (service['ratings'].isNotEmpty) ...[
                    Text(
                      'Reviews:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...service['ratings'].map<Widget>((rating) {
                      final r = Rating.fromMap(rating);
                      return RatingCardWidget(rating: r);
                    }).toList(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}