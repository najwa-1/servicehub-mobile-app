class Rating {
  final String name;
  final double rating;
  final String comment;
  final String? date;

  Rating({
    required this.name,
    required this.rating,
    required this.comment,
    this.date,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      name: map['name'] ?? 'Anonymous',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}
