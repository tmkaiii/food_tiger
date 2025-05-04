// main.dart - optimized with auth flow
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_tiger/screens/forgot_password_screen.dart';
import 'package:food_tiger/screens/seller/seller_dashboard.dart';
import 'package:food_tiger/screens/user_profile_screen.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart'; // Added user provider

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FoodTigerApp());
}

class FoodTigerApp extends StatelessWidget {
  const FoodTigerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()), // Added for user management
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        // Other providers can be added here
      ],
      child: Consumer<UserAuthProvider>(
        builder: (ctx, authProvider, _) {
          // Initialize auth state check
          _checkCurrentUser(authProvider);

          return MaterialApp(
            title: 'Food Tiger',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // Using ColorScheme for modern theming approach
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
              // Unified button style
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
              // Unified input field style
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12
                ),
              ),
            ),
            home: const AuthWrapper(),
            // Define routes
            routes: {
              '/login': (ctx) => const LoginScreen(),
              '/home': (ctx) => const HomeScreen(),
              '/profile': (ctx) =>  UserProfileScreen(),
              '/forgot-password': (ctx) => ForgotPasswordScreen(),
              '/seller-dashboard': (ctx) => SellerDashboard(),
              // Add more routes as needed
            },
          );
        },
      ),
    );
  }

  Future<void> _checkCurrentUser(UserAuthProvider authProvider) async {
    if (!authProvider.isLoading && authProvider.currentUser == null) {
      // Only check once
      authProvider.checkCurrentUser();
    }
  }
}

// Auth wrapper to manage authentication flow
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthProvider>(
      builder: (ctx, authProvider, _) {
        // Show loading indicator while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // First app launch always shows splash screen
        if (!authProvider.hasCheckedAuth) {
          return const SplashScreen();
        }

        // After splash screen, direct based on auth state
        if (authProvider.currentUser != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}