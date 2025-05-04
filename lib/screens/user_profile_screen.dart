// screens/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

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

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.currentUser?.name);
    _phoneController = TextEditingController(text: userProvider.currentUser?.phone);
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
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
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
      await _authService.signOut();

      // Clear user provider data
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
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
        label: Text('Become a Seller'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
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
      body: Consumer<UserProvider>(
        builder: (ctx, userProvider, _) {
          if (userProvider.currentUser == null) {
            return Center(child: Text('No user data found'));
          }

          return _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),

                // Email (non-editable)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(userProvider.currentUser!.email),
                  ),
                ),

                // Form with editable fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _isEditing
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
                        ),
                      ),

                      // Phone
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _isEditing
                              ? TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone',
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
                            title: Text('Phone'),
                            subtitle: Text(userProvider.currentUser!.phone),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Update profile button (only when editing)
                if (_isEditing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            // Reset controllers to original values
                            _nameController.text = userProvider.currentUser!.name;
                            _phoneController.text = userProvider.currentUser!.phone;
                          });
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),

                SizedBox(height: 24),

                // Become Seller / Toggle Mode button
                _buildBecomeSellerButton(),

                SizedBox(height: 16),

                // Sign out button
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}