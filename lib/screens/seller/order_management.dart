// screens/seller/order_management.dart
import 'package:flutter/material.dart';
import 'order_list.dart';

class OrderManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Delivering'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrdersList(status: 'pending'),
            OrdersList(status: 'delivering'),
            OrdersList(status: 'completed'),
          ],
        ),
      ),
    );
  }
}