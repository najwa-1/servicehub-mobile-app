import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repository/RatingRepository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_and_service/comment_field_widget.dart';
import '../../widgets/rating_and_service/name_field_widget.dart';
import '../../widgets/rating_and_service/rating_stars_widget.dart';
import '../../widgets/rating_and_service/submit_button_widget.dart';



class RatingPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final Function(Map<String, dynamic>) onRatingSubmitted;

  RatingPage({
    required this.service,
    required this.onRatingSubmitted,
  });

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final RatingRepository _ratingRepository = RatingRepository();
  double _rating = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  void _handleSubmitRating() {
    Provider.of<RatingRepository>(context, listen: false).submitRating(
      context: context,
      service: widget.service,
      name: _nameController.text.trim(),
      comment: _commentController.text.trim(),
      rating: _rating,
      onRatingSubmitted: widget.onRatingSubmitted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceId = widget.service['id'];
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.border,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Rate - ${widget.service['name']}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: screenHeight * 0.6),
            padding: EdgeInsets.all(20),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primary, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate this service',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    RatingStarsWidget(
                      rating: _rating,
                      onRatingChanged: (newRating) {
                        setState(() {
                          _rating = newRating;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    NameFieldWidget(controller: _nameController),
                    SizedBox(height: 16),
                    CommentFieldWidget(controller: _commentController),
                    SizedBox(height: 20),
                    SubmitButtonWidget(onPressed: _handleSubmitRating),
                    SizedBox(height: 20),
                    StreamBuilder(
                      stream: _ratingRepository.getServiceRatings(serviceId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        final ratings = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: ratings.length,
                          itemBuilder: (context, index) {
                            final rating = ratings[index].data();
                            
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
