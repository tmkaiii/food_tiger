// // screens/seller/edit_restaurant_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/seller_provider.dart';
// import '../../models/restaurant_model.dart';
//
// class EditRestaurantScreen extends StatefulWidget {
//   static const routeName = '/seller/edit-restaurant';
//
//   @override
//   _EditRestaurantScreenState createState() => _EditRestaurantScreenState();
// }
//
// class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
//   final _formKey = GlobalKey<FormState>();
//   var _editedRestaurant = RestaurantModel(
//     id: '',
//     name: '',
//     description: '',
//     imageUrl: '',
//   );
//   var _isInit = true;
//
//   @override
//   void didChangeDependencies() {
//     if (_isInit) {
//       final id = ModalRoute.of(context)!.settings.arguments as String?;
//       if (id != null && id.isNotEmpty) {
//         final existing = Provider.of<SellerProvider>(context, listen: false)
//             .findById(id);
//         _editedRestaurant = RestaurantModel(
//           id: existing.id,
//           name: existing.name,
//           description: existing.description,
//           imageUrl: existing.imageUrl,
//           rating: existing.rating,
//           deliveryTimeMin: existing.deliveryTimeMin,
//           deliveryTimeMax: existing.deliveryTimeMax,
//           categories: existing.categories,
//         );
//       }
//     }
//     _isInit = false;
//     super.didChangeDependencies();
//   }
//
//   void _saveForm() {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     final provider = Provider.of<SellerProvider>(context, listen: false);
//     if (_editedRestaurant.id.isNotEmpty) {
//       provider.updateRestaurant(_editedRestaurant.id, _editedRestaurant);
//     } else {
//       provider.addRestaurant(_editedRestaurant);
//     }
//     Navigator.of(context).pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_editedRestaurant.id.isNotEmpty ? 'Edit Restaurant' : 'Add Restaurant'),
//         actions: [
//           IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextFormField(
//                   initialValue: _editedRestaurant.name,
//                   decoration: InputDecoration(labelText: 'Name'),
//                   textInputAction: TextInputAction.next,
//                   validator: (value) => value!.isEmpty ? 'Please enter a name.' : null,
//                   onSaved: (value) => _editedRestaurant = _editedRestaurant.copyWith(name: value!),
//                 ),
//                 TextFormField(
//                   initialValue: _editedRestaurant.description,
//                   decoration: InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                   validator: (value) => value!.isEmpty ? 'Please enter a description.' : null,
//                   onSaved: (value) => _editedRestaurant = _editedRestaurant.copyWith(description: value!),
//                 ),
//                 TextFormField(
//                   initialValue: _editedRestaurant.imageUrl,
//                   decoration: InputDecoration(labelText: 'Image URL'),
//                   textInputAction: TextInputAction.next,
//                   validator: (value) => value!.isEmpty ? 'Please enter an image URL.' : null,
//                   onSaved: (value) => _editedRestaurant = _editedRestaurant.copyWith(imageUrl: value!),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         initialValue: _editedRestaurant.deliveryTimeMin.toString(),
//                         decoration: InputDecoration(labelText: 'Min Delivery (min)'),
//                         keyboardType: TextInputType.number,
//                         validator: (value) => int.tryParse(value!) == null ? 'Enter a number.' : null,
//                         onSaved: (value) => _editedRestaurant = _editedRestaurant.copyWith(deliveryTimeMin: int.parse(value!)),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: TextFormField(
//                         initialValue: _editedRestaurant.deliveryTimeMax.toString(),
//                         decoration: InputDecoration(labelText: 'Max Delivery (min)'),
//                         keyboardType: TextInputType.number,
//                         validator: (value) => int.tryParse(value!) == null ? 'Enter a number.' : null,
//                         onSaved: (value) => _editedRestaurant = _editedRestaurant.copyWith(deliveryTimeMax: int.parse(value!)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextFormField(
//                   initialValue: _editedRestaurant.categories.join(', '),
//                   decoration: InputDecoration(labelText: 'Categories (comma separated)'),
//                   onSaved: (value) => _editedRestaurant = _editedRestaurant.copyWith(
//                     categories: value!.split(',').map((e) => e.trim()).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
