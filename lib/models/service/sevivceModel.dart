class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
