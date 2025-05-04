// main.dart - optimized version
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Other providers can be added here
      ],
      child: MaterialApp(
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
      ),
    );
  }
}

// Auth wrapper to manage authentication flow
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading indicator while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Decide which screen to show based on authentication state
    // During first app launch, show splash screen regardless of auth state
    return const SplashScreen();

    // Decide which screen to show based on authentication state
    // if (authProvider.isLoggedIn) {
    //   return const HomeScreen();
    // } else {
    //   return const LoginScreen();
    // }
  }
}