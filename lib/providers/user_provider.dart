// providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser; // Changed from _user to _currentUser for consistency
  bool _isSellerMode = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser; // Changed getter name to match
  bool get isSellerMode => _isSellerMode && (_currentUser?.isSeller ?? false);
  bool get isLoading => _isLoading;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    _isSellerMode = false;
    notifyListeners();
  }

  // Toggle between buyer and seller mode
  void toggleSellerMode() {
    if (_currentUser?.isSeller ?? false) {
      _isSellerMode = !_isSellerMode;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String name, String phone) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      // Update Firestore
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'name': name,
        'phone': phone,
      });

      // Update local model
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        phone: phone,
        roles: _currentUser!.roles,
        shopName: _currentUser!.shopName,
      );

      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Register as seller
  Future<void> registerAsSeller(String shopName, String description) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      // Update user roles in Firestore
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'roles': FieldValue.arrayUnion(['seller']),
        'shopName': shopName,
      });

      // Create seller document
      await _firestore.collection('sellers').doc(_currentUser!.id).set({
        'userId': _currentUser!.id,
        'shopName': shopName,
        'description': description,
        'logoUrl': null,
        'restaurantIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update local model
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        phone: _currentUser!.phone,
        roles: [..._currentUser!.roles, 'seller'],
        shopName: shopName,
      );

      notifyListeners();
    } catch (e) {
      print('Error registering as seller: $e');
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}