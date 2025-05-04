// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../widgets/carousel_section.dart';
import '../widgets/category_selector.dart';
import 'restaurant_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  // 餐厅数据转换为对象模型
  final List<Restaurant> _restaurants = [
    Restaurant(
      id: '1',
      name: 'Malay Cookhouse',
      description: 'Malaysian traditional food',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Malaysian'],
    ),
    Restaurant(
      id: '2',
      name: 'Pak Tam',
      description: 'Asam Pedas',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Malaysian'],
    ),
    Restaurant(
      id: '3',
      name: 'Nasi Lemak Wanjo',
      description: 'You can find the most delicious Nasi Lemak here',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Malaysian'],
    ),
    Restaurant(
      id: '4',
      name: 'Xin Eel Ma',
      description: 'You can find any local Chinese food here',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Chinese'],
    ),
  ];

  List<Restaurant> _filteredRestaurants = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = _restaurants;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 搜索餐厅
  void _searchRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterRestaurantsByCategory(_selectedCategory);
      } else {
        _filteredRestaurants = _restaurants.where((restaurant) {
          return restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
              restaurant.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // 按类别过滤餐厅
  void _filterRestaurantsByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants.where((restaurant) {
          return restaurant.categories.contains(category);
        }).toList();
      }
    });
  }

  // 导航到餐厅详情页
  void _navigateToRestaurantDetail(Restaurant restaurant) {
    // 实现餐厅详情页导航
    print('Navigate to restaurant detail: ${restaurant.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Tiger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // 导航到购物车页面
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 轮播图部分
          const CarouselSection(),

          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _searchRestaurants,
            ),
          ),

          // 类别选择器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CategorySelector(),
          ),

          const SizedBox(height: 10),

          // 餐厅列表
          Expanded(
            child: RestaurantList(
              restaurants: _filteredRestaurants,
              onTap: _navigateToRestaurantDetail,
              showViewAll: true,
              onViewAllTap: () {
                // 导航到所有餐厅页面
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // 根据导航栏选项执行相应操作
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF008080),
      ),
    );
  }
}