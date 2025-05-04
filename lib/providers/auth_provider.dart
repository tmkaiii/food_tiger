// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class UserAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _hasCheckedAuth = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasCheckedAuth => _hasCheckedAuth;

  // Register with email and password
  Future<UserModel?> register(
      String name,
      String email,
      String password,
      String phone,
      DateTime? dateOfBirth
      ) async {
    try {
      _setLoading(true);

      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data to Firestore
      await _saveUserData(
        result.user!.uid,
        name,
        email,
        phone,
      );

      // Create and return user model
      _currentUser = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        roles: ['buyer'],
      );

      notifyListeners();
      return _currentUser;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      _setLoading(true);

      // Sign in with Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      await _fetchUserData(result.user!.uid);

      notifyListeners();
      return _currentUser;
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      _setLoading(true);

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return null; // User canceled the sign-in flow
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      UserCredential result = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      // If new user, save data to Firestore
      if (!userDoc.exists) {
        String name = result.user!.displayName ?? '';
        String email = result.user!.email ?? '';
        String phone = result.user!.phoneNumber ?? '';

        await _saveUserData(
          result.user!.uid,
          name,
          email,
          phone,
        );

        _currentUser = UserModel(
          id: result.user!.uid,
          name: name,
          email: email,
          phone: phone,
          roles: ['buyer'],
        );
      } else {
        // Get existing user data
        await _fetchUserData(result.user!.uid);
      }

      notifyListeners();
      return _currentUser;
    } catch (e) {
      print('Error during Google sign in: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user is already logged in
  Future<UserModel?> checkCurrentUser() async {
    try {
      _setLoading(true);
      final user = _auth.currentUser;

      if (user != null) {
        await _fetchUserData(user.uid);
      }

      _hasCheckedAuth = true;
      notifyListeners();
      return _currentUser;
    } catch (e) {
      print('Error checking current user: $e');
      _hasCheckedAuth = true;
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        _currentUser = UserModel(
          id: userId,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          roles: List<String>.from(userData['roles'] ?? ['buyer']),
          shopName: userData['shopName'],
        );
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(
      String userId,
      String name,
      String email,
      String phone,
      ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'roles': ['buyer'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}