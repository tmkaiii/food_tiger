// providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;

  // Get orders for a specific seller
  Future<void> fetchSellerOrders(String sellerId) async {
    _setLoading(true);
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('orderDate', descending: true)
          .get();

      _orders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      }))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching seller orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get orders filtered by status
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _setLoading(true);
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });

      // Update local list
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        // Create a new order with updated status
        final currentOrder = _orders[index];
        final updatedOrder = OrderModel(
          id: currentOrder.id,
          userId: currentOrder.userId, // Use userId instead of customerId
          restaurantId: currentOrder.restaurantId,
          restaurantName: currentOrder.restaurantName,
          items: currentOrder.items,
          totalAmount: currentOrder.totalAmount,
          deliveryAddress: currentOrder.deliveryAddress,
          paymentMethod: currentOrder.paymentMethod,
          createdAt: currentOrder.createdAt,
          status: OrderStatus.values.firstWhere((s) => s.toString().split('.').last == newStatus),
        );

        _orders[index] = updatedOrder;
      }

      notifyListeners();
    } catch (e) {
      print('Error updating order status: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get order details
  Future<OrderModel?> getOrderDetails(String orderId) async {
    try {
      final docSnapshot = await _firestore.collection('orders').doc(orderId).get();

      if (docSnapshot.exists) {
        return OrderModel.fromJson({
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error getting order details: $e');
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}