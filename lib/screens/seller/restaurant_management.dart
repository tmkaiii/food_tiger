// screens/seller/restaurant_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/seller_provider.dart';
import '../../models/restaurant_model.dart';
import '../../widgets/restaurant_item.dart';

class RestaurantManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Management')),
      body: Consumer<SellerProvider>(
        builder: (ctx, sellerProvider, _) {
          return ListView(
            children: [
              // Restaurant list
              ...sellerProvider.sellerRestaurants.map((restaurant) =>
                  RestaurantItem(
                    restaurant: restaurant,
                    onEdit: () => _editRestaurant(context, restaurant),
                    onDelete: () => _deleteRestaurant(context, restaurant),
                  ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addNewRestaurant(context),
      ),
    );
  }

  void _addNewRestaurant(BuildContext context) {
    // Navigate to add restaurant page
  }

  void _editRestaurant(BuildContext context, RestaurantModel restaurant) {
    // Navigate to edit restaurant page
  }

  void _deleteRestaurant(BuildContext context, RestaurantModel restaurant) {
    // Show confirmation dialog and delete restaurant
  }
}