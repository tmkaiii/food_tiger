// providers/restaurant_provider.dart
import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../models/food_model.dart';
import '../services/firestore_service.dart';

class RestaurantProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  List<FoodModel> _foods = [];
  bool _isLoading = false;

  List<RestaurantModel> get restaurants => [..._restaurants];
  List<RestaurantModel> get filteredRestaurants => [..._filteredRestaurants];
  List<FoodModel> get foods => [..._foods];
  bool get isLoading => _isLoading;

  // Add this setter method
  set filteredRestaurants(List<RestaurantModel> restaurants) {
    _filteredRestaurants = restaurants;
    notifyListeners();
  }

  Future<void> fetchRestaurants() async {
    _setLoading(true);
    try {
      _restaurants = await _firestoreService.getRestaurants();
      _filteredRestaurants = [..._restaurants]; // Initialize filtered list with all restaurants
      notifyListeners();
    } catch (e) {
      print('Error in provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFoodsByRestaurant(String restaurantId) async {
    _setLoading(true);
    try {
      _foods = await _firestoreService.getFoodsByRestaurant(restaurantId);
      notifyListeners();
    } catch (e) {
      print('Error in provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}