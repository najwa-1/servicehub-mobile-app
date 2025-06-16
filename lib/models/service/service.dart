import '../../models/rating.dart';


class Service {
  String? id;
  String? name;
  String? user;
  String? userId;
  String? details;
  String? price;
  String? imageBytes;
  String? imageUrl;
  String? imagePath;
  List<Rating> ratings;

  Service({
    this.id,
    this.name,
    this.user,
    this.userId,
    this.details,
    this.price,
    this.imageBytes,
    this.imageUrl,
    this.imagePath,
    List<Rating>? ratings,
  }) : ratings = ratings ?? [];

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      user: map['user'],
      userId: map['userId'],
      details: map['details'],
      price: map['price']?.toString(),
      imageBytes: map['imageBytes'],
      imageUrl: map['imageUrl'],
      imagePath: map['imagePath'],
      ratings: map['ratings'] != null
          ? List<Rating>.from(
              (map['ratings'] as List).map((r) => Rating.fromMap(r)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user': user,
      'userId': userId,
      'details': details,
      'price': price,
      'imageBytes': imageBytes,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'ratings': ratings.map((r) => r.toMap()).toList(),
    };
  }
}
