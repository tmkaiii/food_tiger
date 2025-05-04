// main.dart - simplified
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/seller_provider.dart';
import 'screens/seller/become_seller_screen.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/seller/seller_dashboard.dart';
import 'screens/seller/food_management.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FoodTigerApp());
}

class FoodTigerApp extends StatelessWidget {
  const FoodTigerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => SellerProvider()),
      ],
      child: MaterialApp(
        title: 'Food Tiger',
        debugShowCheckedModeBanner: false,
        theme: _buildAppTheme(),
        home: const AppStartup(),
        routes: {
          '/login': (ctx) => const LoginScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/profile': (ctx) => UserProfileScreen(),
          '/forgot-password': (ctx) => ForgotPasswordScreen(),
          '/seller-dashboard': (ctx) => SellerDashboard(),
          '/become-seller': (ctx) => BecomeSellerScreen(),
          // '/food-management': (ctx) => FoodManagement(),
        }
        ),
    );
  }

  // Extracted theme configuration into a separate method
  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF008080),
        primary: const Color(0xFF008080),
        secondary: Colors.amber,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF008080),
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008080),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

// Combined startup and auth checking
class AppStartup extends StatefulWidget {
  const AppStartup({Key? key}) : super(key: key);

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _checkedAuth = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    await authProvider.checkCurrentUser();
    setState(() {
      _checkedAuth = true;
    });
  }

  Future<void> _checkCurrentUser(UserAuthProvider authProvider) async {
    if (!authProvider.isLoading && authProvider.currentUser == null) {
      final user = await authProvider.checkCurrentUser();
      if (user != null) {
        // 同步到UserProvider
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // First show splash screen
    if (!_checkedAuth) {
      return const SplashScreen();
    }

    // Then check auth status
    final authProvider = Provider.of<UserAuthProvider>(context);
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Direct to appropriate screen
    if (authProvider.currentUser != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}