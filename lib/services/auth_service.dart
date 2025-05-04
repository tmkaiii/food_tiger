// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/Password Registration
  Future<UserModel?> registerWithEmailPassword(
      String email, String password, String name, String phone) async {
    try {
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

      return UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        roles: ['buyer'],
      );
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  // Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
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

      // Once signed in, return the UserCredential
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

        return UserModel(
          id: result.user!.uid,
          name: name,
          email: email,
          phone: phone,
          roles: ['buyer'],
        );
      } else {
        // Return existing user data
        return UserModel.fromJson({
          'id': result.user!.uid,
          ...userDoc.data() as Map<String, dynamic>,
        });
      }
    } catch (e) {
      print('Error during Google sign in: $e');
      return null;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(
      String userId, String name, String email, String phone) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'roles': ['buyer'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Forgot Password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson({
          'id': user.uid,
          ...userDoc.data() as Map<String, dynamic>,
        });
      }
    }

    return null;
  }

  // services/auth_service.dart (add this method)
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson({
          'id': result.user!.uid,
          ...userDoc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}