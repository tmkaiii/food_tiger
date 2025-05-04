// models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final List<String> roles;
  final String? shopName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.dateOfBirth,
    this.roles = const ['buyer'],
    this.shopName,
  });

  bool get isSeller => roles.contains('seller');

  // FromJson constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      roles: List<String>.from(json['roles'] ?? ['buyer']),
      shopName: json['shopName'],
    );
  }

  // ToJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'roles': roles,
      'shopName': shopName,
    };
  }
}