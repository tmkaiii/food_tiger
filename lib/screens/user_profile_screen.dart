// screens/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart'; // Fixed import path

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load user data after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

    // If UserProvider has no data but AuthProvider does, sync them
    if (userProvider.currentUser == null && authProvider.currentUser != null) {
      userProvider.setUser(authProvider.currentUser!);
    }

    // Initialize controllers with user data
    setState(() {
      _nameController = TextEditingController(text: userProvider.currentUser?.name ?? '');
      _phoneController = TextEditingController(text: userProvider.currentUser?.phone ?? '');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserProfile(
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Info Update Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error when updating info: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use AuthProvider for consistency
      await Provider.of<UserAuthProvider>(context, listen: false).signOut();

      // Clear user provider data
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error when logging out: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBecomeSellerButton() {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.currentUser?.isSeller ?? false) {
      return ElevatedButton.icon(
        onPressed: () {
          userProvider.toggleSellerMode();
          if (userProvider.isSellerMode) {
            Navigator.of(context).pushNamed('/seller-dashboard');
          }
        },
        icon: Icon(Icons.storefront),
        label: Text(
          userProvider.isSellerMode
              ? 'Switch to Buyer Mode'
              : 'Switch to Seller Mode',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed('/become-seller');
        },
        icon: Icon(Icons.store),
        label: Text('Become Seller'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // display isLoading
    if (userProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('My Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // display error when not data
    if (userProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Profile data cannot be loaded'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Refresh to load profile data
                  final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
                  authProvider.checkCurrentUser().then((user) {
                    if (user != null) {
                      Provider.of<UserProvider>(context, listen: false).setUser(user);
                    }
                  });
                },
                child: Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    // Display normal profile data
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          // Edit button
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // userProfile
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
              ),
              SizedBox(height: 20),

              // Profile Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Name
                      _isEditing
                          ? TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      )
                          : ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Name'),
                        subtitle: Text(userProvider.currentUser!.name),
                      ),

                      Divider(),

                      // Email(display only not edit)
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Email'),
                        subtitle: Text(userProvider.currentUser!.email),
                      ),

                      Divider(),

                      // Phone Number
                      _isEditing
                          ? TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      )
                          : ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('Phone Number'),
                        subtitle: Text(userProvider.currentUser!.phone),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // save after edit button and cancel edit button
              if (_isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          // Reset to original value
                          _nameController.text = userProvider.currentUser!.name;
                          _phoneController.text = userProvider.currentUser!.phone;
                        });
                      },
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: _isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text('Save'),
                    ),
                  ],
                ),

              SizedBox(height: 20),

              // Seller function
              _buildBecomeSellerButton(),

              SizedBox(height: 20),

              // Logout button
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}