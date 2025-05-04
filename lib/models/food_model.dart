// lib/models/food_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> categories;
  final bool isAvailable;
  final double rating;
  final int ratingCount;

  FoodModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.categories = const [],
    this.isAvailable = true,
    this.rating = 0,
    this.ratingCount = 0,
  });

  // Factory constructor to create a FoodModel from a Firestore document
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  // Convert the FoodModel instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categories': categories,
      'isAvailable': isAvailable,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  // Create a copy of this FoodModel with given fields replaced with new values
  FoodModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? categories,
    bool? isAvailable,
    double? rating,
    int? ratingCount,
  }) {
    return FoodModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}