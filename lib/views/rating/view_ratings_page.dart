import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../repository/RatingRepository.dart';
import '../../theme/app_colors.dart';


class ViewRatingsPage extends StatefulWidget {
  final Map<String, dynamic> service;

  const ViewRatingsPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<ViewRatingsPage> createState() => _ViewRatingsPageState();
}

class _ViewRatingsPageState extends State<ViewRatingsPage> {
  final RatingRepository _ratingRepository = RatingRepository();

  @override
  Widget build(BuildContext context) {
    final serviceId = widget.service['id'] ?? widget.service['serviceId'] ?? '';
    final serviceName = widget.service['name'] ?? widget.service['serviceName'] ?? 'Service';

    return Scaffold(
      backgroundColor: AppColors.border,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Ratings - $serviceName',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: _ratingRepository.getServiceRatings(serviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading ratings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Ratings Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This service hasn\'t received any ratings yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final ratings = snapshot.data!.docs;
          
          double totalRating = 0;
          for (var rating in ratings) {
            final ratingData = rating.data() as Map<String, dynamic>;
            totalRating += (ratingData['rating'] ?? 0).toDouble();
          }
          double averageRating = totalRating / ratings.length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < averageRating.floor()
                                    ? Icons.star
                                    : (index < averageRating && averageRating % 1 != 0)
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              );
                            }),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '${averageRating.toStringAsFixed(1)}/5',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Based on ${ratings.length} ${ratings.length == 1 ? 'review' : 'reviews'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                Text(
                  'All Reviews',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                
                SizedBox(height: 12),
                
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: ratings.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ratingDoc = ratings[index];
                    final ratingData = ratingDoc.data() as Map<String, dynamic>;
                    
                    final name = ratingData['name'] ?? 'Anonymous';
                    final comment = ratingData['comment'] ?? '';
                    final rating = (ratingData['rating'] ?? 0).toDouble();
                    final dateString = ratingData['date'] ?? '';
                    
                    String formattedDate = 'Recently';
                    if (dateString.isNotEmpty) {
                      try {
                        final date = DateTime.parse(dateString);
                        final now = DateTime.now();
                        final difference = now.difference(date).inDays;
                        
                        if (difference == 0) {
                          formattedDate = 'Today';
                        } else if (difference == 1) {
                          formattedDate = 'Yesterday';
                        } else if (difference < 7) {
                          formattedDate = '$difference days ago';
                        } else if (difference < 30) {
                          final weeks = (difference / 7).floor();
                          formattedDate = '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
                        } else {
                          final months = (difference / 30).floor();
                          formattedDate = '$months ${months == 1 ? 'month' : 'months'} ago';
                        }
                      } catch (e) {
                        formattedDate = 'Recently';
                      }
                    }

                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 8),
                          
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < rating.floor()
                                    ? Icons.star
                                    : (starIndex < rating && rating % 1 != 0)
                                        ? Icons.star_half
                                        : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ),
                          
                          if (comment.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              comment,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}