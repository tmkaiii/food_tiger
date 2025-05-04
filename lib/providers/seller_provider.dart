// providers/seller_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/seller_model.dart';
import '../models/food_model.dart';

class SellerProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SellerModel? _sellerData;
  List<RestaurantModel> _sellerRestaurants = [];
  bool _isLoading = false;

  SellerModel? get sellerData => _sellerData;
  List<RestaurantModel> get sellerRestaurants => [..._sellerRestaurants];
  bool get isLoading => _isLoading;

  // Fetch seller data by user ID
  Future<void> fetchSellerData(String userId) async {
    _setLoading(true);
    try {
      final sellerDoc = await _firestore.collection('sellers').doc(userId).get();

      if (sellerDoc.exists) {
        _sellerData = SellerModel.fromJson({
          'id': sellerDoc.id,
          ...sellerDoc.data()!,
        });
        await fetchSellerRestaurants();
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching seller data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch restaurants owned by seller
  Future<void> fetchSellerRestaurants() async {
    if (_sellerData == null) return;

    _setLoading(true);
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('sellerId', isEqualTo: _sellerData!.id)
          .get();

      _sellerRestaurants = querySnapshot.docs
          .map((doc) => RestaurantModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching seller restaurants: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new restaurant
  Future<void> addRestaurant(RestaurantModel restaurant) async {
    if (_sellerData == null) return;

    _setLoading(true);
    try {
      // Add the sellerId to the restaurant data
      final restaurantData = restaurant.toJson();
      restaurantData['sellerId'] = _sellerData!.id;

      // Add to Firestore
      final docRef = await _firestore.collection('restaurants').add(restaurantData);

      // Update local list
      final newRestaurant = RestaurantModel.fromJson({
        'id': docRef.id,
        ...restaurantData,
      });
      _sellerRestaurants.add(newRestaurant);

      // Update the restaurantIds in seller document
      await _firestore.collection('sellers').doc(_sellerData!.id).update({
        'restaurantIds': FieldValue.arrayUnion([docRef.id]),
      });

      notifyListeners();
    } catch (e) {
      print('Error adding restaurant: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update a restaurant
  Future<void> updateRestaurant(RestaurantModel restaurant) async {
    _setLoading(true);
    try {
      await _firestore.collection('restaurants').doc(restaurant.id).update(
        restaurant.toJson(),
      );

      // Update local list
      final index = _sellerRestaurants.indexWhere((r) => r.id == restaurant.id);
      if (index >= 0) {
        _sellerRestaurants[index] = restaurant;
      }

      notifyListeners();
    } catch (e) {
      print('Error updating restaurant: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a restaurant
  Future<void> deleteRestaurant(String restaurantId) async {
    if (_sellerData == null) return;

    _setLoading(true);
    try {
      // Delete the restaurant document
      await _firestore.collection('restaurants').doc(restaurantId).delete();

      // Remove from local list
      _sellerRestaurants.removeWhere((r) => r.id == restaurantId);

      // Update the restaurantIds in seller document
      await _firestore.collection('sellers').doc(_sellerData!.id).update({
        'restaurantIds': FieldValue.arrayRemove([restaurantId]),
      });

      notifyListeners();
    } catch (e) {
      print('Error deleting restaurant: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a food item to a restaurant
  Future<void> addFoodItem(String restaurantId, FoodModel food) async {
    _setLoading(true);
    try {
      // Add the restaurantId to the food data
      final foodData = food.toJson();
      foodData['restaurantId'] = restaurantId;

      // Add to Firestore
      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('foods')
          .add(foodData);

      notifyListeners();
    } catch (e) {
      print('Error adding food item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update a food item
  Future<void> updateFoodItem(String restaurantId, FoodModel food) async {
    _setLoading(true);
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('foods')
          .doc(food.id)
          .update(food.toJson());

      notifyListeners();
    } catch (e) {
      print('Error updating food item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String restaurantId, String foodId) async {
    _setLoading(true);
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('foods')
          .doc(foodId)
          .delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting food item: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update shop profile
  Future<void> updateSellerProfile(String shopName, String description, String? logoUrl) async {
    if (_sellerData == null) return;

    _setLoading(true);
    try {
      await _firestore.collection('sellers').doc(_sellerData!.id).update({
        'shopName': shopName,
        'description': description,
        if (logoUrl != null) 'logoUrl': logoUrl,
      });

      // Update local data
      _sellerData = SellerModel(
        id: _sellerData!.id,
        userId: _sellerData!.userId,
        shopName: shopName,
        description: description,
        logoUrl: logoUrl ?? _sellerData!.logoUrl,
        restaurantIds: _sellerData!.restaurantIds,
      );

      notifyListeners();
    } catch (e) {
      print('Error updating seller profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}