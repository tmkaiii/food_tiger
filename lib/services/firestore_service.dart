import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 餐厅相关方法
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      return snapshot.docs
          .map((doc) => RestaurantModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      // 处理错误
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  // 食品相关方法
  Future<List<FoodModel>> getFoodsByRestaurant(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('foods')
          .get();

      return snapshot.docs
          .map((doc) => FoodModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching foods: $e');
      return [];
    }
  }

  // 订单相关方法
  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').add({
        'userId': order.userId,
        'restaurantId': order.restaurantId,
        'items': order.items.map((item) => {
          'foodId': item.foodId,
          'quantity': item.quantity,
          'price': item.price,
          // 其他订单项属性
        }).toList(),
        'totalAmount': order.totalAmount,
        'status': 'pending', // 初始状态
        'createdAt': FieldValue.serverTimestamp(),
        // 其他订单属性
      });
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // 获取用户历史订单
  // Future<List<OrderModel>> getUserOrders(String userId) async {
  //   // 实现获取用户订单的方法
  //   // ...
  // }

// 其他数据库方法...
}