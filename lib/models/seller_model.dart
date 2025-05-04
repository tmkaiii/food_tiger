// models/seller_model.dart
class SellerModel {
  final String id;
  final String userId;
  final String shopName;
  final String description;
  final String? logoUrl;
  final List<String> restaurantIds; // Associated restaurant IDs

  SellerModel({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.description,
    this.logoUrl,
    this.restaurantIds = const [],
  });

// From JSON conversion
  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      shopName: json['shopName'] ?? '',
      description: json['description'] ?? '',
      logoUrl: json['logoUrl'],
      restaurantIds: List<String>.from(json['restaurantIds'] ?? []),
    );
  }

  // To JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shopName': shopName,
      'description': description,
      'logoUrl': logoUrl,
      'restaurantIds': restaurantIds,
      // Note: 'id' is typically not included in toJson since Firestore uses the document ID
    };
  }
}