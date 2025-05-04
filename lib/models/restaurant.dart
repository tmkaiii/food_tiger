// models/restaurant.dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final List<String> categories;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.rating = 4.5,
    this.deliveryTimeMin = 30,
    this.deliveryTimeMax = 40,
    this.categories = const ['All'],
  });

  // 工厂构造函数，从JSON转换
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      deliveryTimeMin: json['deliveryTimeMin'] ?? 30,
      deliveryTimeMax: json['deliveryTimeMax'] ?? 40,
      categories: List<String>.from(json['categories'] ?? ['All']),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': imageUrl,
      'rating': rating,
      'deliveryTimeMin': deliveryTimeMin,
      'deliveryTimeMax': deliveryTimeMax,
      'categories': categories,
    };
  }
}