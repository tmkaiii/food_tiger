// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant_model.dart';
import '../providers/restaurant_provider.dart';
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
  final List<RestaurantModel> _restaurants = [
    RestaurantModel(
      id: '1',
      name: 'Malay Cookhouse',
      description: 'Malaysian traditional food',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Malaysian'],
    ),
    RestaurantModel(
      id: '2',
      name: 'Pak Tam',
      description: 'Asam Pedas',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Malaysian'],
    ),
    RestaurantModel(
      id: '3',
      name: 'Nasi Lemak Wanjo',
      description: 'You can find the most delicious Nasi Lemak here',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Malaysian'],
    ),
    RestaurantModel(
      id: '4',
      name: 'Xin Eel Ma',
      description: 'You can find any local Chinese food here',
      imageUrl: 'https://via.placeholder.com/150',
      categories: ['All', 'Chinese'],
    ),
  ];

  List<RestaurantModel> _filteredRestaurants = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Loading Firestore data
    Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search restaurants
  void _searchRestaurants(String query) {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    final allRestaurants = provider.restaurants;

    if (query.isEmpty) {
      _filterRestaurantsByCategory(_selectedCategory, allRestaurants);
    } else {
      final filtered = allRestaurants.where((restaurant) {
        return restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.description.toLowerCase().contains(query.toLowerCase());
      }).toList();

      provider.filteredRestaurants = filtered;
    }
  }

  // Filter restaurants by category
  void _filterRestaurantsByCategory(String category, [List<RestaurantModel>? restaurants]) {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    final allRestaurants = restaurants ?? provider.restaurants;
    setState(() {
      _selectedCategory = category;
    });

    if (category == 'All') {
      provider.filteredRestaurants = allRestaurants;
    } else {
      provider.filteredRestaurants = allRestaurants.where((restaurant) {
        return restaurant.categories.contains(category);
      }).toList();
    }
  }

  // Navigate to restaurant detail
  void _navigateToRestaurantDetail(RestaurantModel restaurant) {
    Navigator.of(context).pushNamed(
      '/restaurant-detail',
      arguments: restaurant,
    );
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
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (ctx, restaurantProvider, _) {
          if (restaurantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Carousel section
              const CarouselSection(),

              // Search bar
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

              // Category selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _filterRestaurantsByCategory,
                ),
              ),

              const SizedBox(height: 10),

              // Restaurant list
              Expanded(
                child: RestaurantList(
                  restaurants: restaurantProvider.filteredRestaurants,
                  onTap: _navigateToRestaurantDetail,
                  showViewAll: true,
                  onViewAllTap: () {
                    Navigator.of(context).pushNamed('/all-restaurants');
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation based on index
          switch (index) {
            case 0: // Home
              break;
            case 1: // Orders
              Navigator.of(context).pushNamed('/orders');
              break;
            case 2: // Profile
              Navigator.of(context).pushNamed('/profile');
              break;
          }
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