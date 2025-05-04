// lib/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
enum OrderStatus { pending, processing, delivering, completed, cancelled }

class OrderItem {
  final String foodId;
  final String foodName;
  final double price;
  final int quantity;
  final Map<String, bool> addOns;
  final String remarks;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.price,
    required this.quantity,
    this.addOns = const {},
    this.remarks = '',
  });

  double get totalPrice {
    double addOnPrice = 0;
    addOns.forEach((key, selected) {
      if (selected) {
        if (key == 'Rice') addOnPrice += 2.0;
        if (key == 'Egg') addOnPrice += 1.0;
      }
    });
    return (price + addOnPrice) * quantity;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      addOns: Map<String, bool>.from(json['addOns'] ?? {}),
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'price': price,
      'quantity': quantity,
      'addOns': addOns,
      'remarks': remarks,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final bool isPickup;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    this.isPickup = false,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.deliveredAt,
  });
  String get customerName => userId; // If userId is actually the customer name
  DateTime get orderDate => createdAt; // Alias for createdAt

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp conversion
    DateTime? createdAtDateTime;
    DateTime? deliveredAtDateTime;

    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        createdAtDateTime = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is DateTime) {
        createdAtDateTime = json['createdAt'];
      }
    }

    if (json['deliveredAt'] != null) {
      if (json['deliveredAt'] is Timestamp) {
        deliveredAtDateTime = (json['deliveredAt'] as Timestamp).toDate();
      } else if (json['deliveredAt'] is DateTime) {
        deliveredAtDateTime = json['deliveredAt'];
      }
    }

    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      isPickup: json['isPickup'] ?? false,
      paymentMethod: json['paymentMethod'] ?? '',
      status: _statusFromString(json['status'] ?? 'pending'),
      createdAt: createdAtDateTime ?? DateTime.now(),
      deliveredAt: deliveredAtDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'isPickup': isPickup,
      'paymentMethod': paymentMethod,
      'status': _statusToString(status),
      'createdAt': createdAt,
      'deliveredAt': deliveredAt,
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'delivering':
        return OrderStatus.delivering;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.delivering:
        return 'delivering';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  // Get a human-readable status
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivering:
        return 'On the way';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get a color for the status
  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  // Create a copy with new field values
  OrderModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    List<OrderItem>? items,
    double? totalAmount,
    String? deliveryAddress,
    bool? isPickup,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      isPickup: isPickup ?? this.isPickup,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}