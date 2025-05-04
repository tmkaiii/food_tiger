// screens/seller/order_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (ctx, orderProvider, _) {
        final orders = orderProvider.getOrdersByStatus(status);

        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orders.isEmpty) {
          return Center(
            child: Text('No $status orders found'),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (ctx, index) {
            final order = orders[index];
            return OrderItem(
              order: order,
              onStatusChange: (newStatus) {
                orderProvider.updateOrderStatus(order.id, newStatus);
              },
            );
          },
        );
      },
    );
  }
}

class OrderItem extends StatelessWidget {
  final OrderModel order;
  final Function(String) onStatusChange;

  const OrderItem({
    Key? key,
    required this.order,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order.customerName}'),
            Text('Items: ${order.items.length}'),
            Text('Date: ${_formatDate(order.orderDate)}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 'pending')
                  ElevatedButton(
                    onPressed: () => onStatusChange('delivering'),
                    child: const Text('Start Delivery'),
                  ),
                if (order.status == 'delivering')
                  ElevatedButton(
                    onPressed: () => onStatusChange('completed'),
                    child: const Text('Mark as Completed'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}