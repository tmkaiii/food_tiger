// screens/seller/food_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/restaurant_provider.dart';
//
// class FoodManagement extends StatefulWidget {
//   final String restaurantId;
//
//   const FoodManagement({
//     Key? key,
//     required this.restaurantId,
//   }) : super(key: key);
//
//   @override
//   State<FoodManagement> createState() => _FoodManagementState();
// }
//
// class _FoodManagementState extends State<FoodManagement> {
//   bool _isLoading = false;
//   String _selectedCategory = 'All';
//
//   // Controllers for the add/edit food form
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _imageUrlController = TextEditingController();
//   final _categoryController = TextEditingController();
//
//   // Food item being edited (null when adding new food)
//   FoodModel? _editingFood;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFoods();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     _imageUrlController.dispose();
//     _categoryController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadFoods() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       await Provider.of<RestaurantProvider>(context, listen: false)
//           .fetchFoodsByRestaurant(widget.restaurantId);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('加载食品数据失败: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _showAddEditFoodDialog({FoodModel? food}) {
//     // If editing, populate form with food data
//     if (food != null) {
//       _editingFood = food;
//       _nameController.text = food.name;
//       _descriptionController.text = food.description;
//       _priceController.text = food.price.toString();
//       _imageUrlController.text = food.imageUrl;
//       _categoryController.text = food.category;
//     } else {
//       // If adding new food, clear form
//       _editingFood = null;
//       _nameController.clear();
//       _descriptionController.clear();
//       _priceController.clear();
//       _imageUrlController.clear();
//       _categoryController.clear();
//     }
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(food == null ? '添加新菜品' : '编辑菜品'),
//         content: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(labelText: '菜品名称'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '请输入菜品名称';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(labelText: '菜品描述'),
//                   maxLines: 2,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '请输入菜品描述';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(labelText: '价格'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '请输入价格';
//                     }
//                     if (double.tryParse(value) == null) {
//                       return '请输入有效的价格';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _imageUrlController,
//                   decoration: InputDecoration(labelText: '图片URL'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '请输入图片URL';
//                     }
//                     if (!value.startsWith('http')) {
//                       return '请输入有效的URL';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _categoryController,
//                   decoration: InputDecoration(labelText: '类别'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '请输入类别';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: Text('取消'),
//           ),
//           ElevatedButton(
//             onPressed: () => _saveFood(ctx),
//             child: Text('保存'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _saveFood(BuildContext dialogContext) async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final foodData = FoodModel(
//         id: _editingFood?.id ?? '',  // Empty ID for new foods
//         name: _nameController.text,
//         description: _descriptionController.text,
//         price: double.parse(_priceController.text),
//         imageUrl: _imageUrlController.text,
//         category: _categoryController.text,
//         restaurantId: widget.restaurantId,
//       );
//
//       // if (_editingFood == null) {
//       //   // Add new food
//       //   await restaurantProvider.addFoodItem(
//       //     widget.restaurantId,
//       //     foodData,
//       //   );
//       // } else {
//       //   // Update existing food
//       //   await restaurantProvider.updateFoodItem(
//       //     widget.restaurantId,
//       //     foodData,
//       //   );
//       // }
//
//       // Close dialog and show success message
//       Navigator.of(dialogContext).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(_editingFood == null ? '菜品添加成功!' : '菜品更新成功!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('保存菜品时出错: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _deleteFood(FoodModel food) async {
//     // Confirmation dialog
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('确认删除'),
//         content: Text('确定要删除 "${food.name}" 吗?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(false),
//             child: Text('取消'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(true),
//             child: Text('删除', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // await Provider.of<RestaurantProvider>(context, listen: false)
//       //     .deleteFoodItem(widget.restaurantId, food.id);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('菜品已删除')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('删除菜品时出错: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final restaurantProvider = Provider.of<RestaurantProvider>(context);
//     final foods = restaurantProvider.foods;
//
//     // Get unique categories for filtering
//     final categories = ['All', ...{...foods.map((f) => f.category)}];
//
//     // Filter foods by selected category
//     final filteredFoods = _selectedCategory == 'All'
//         ? foods
//         : foods.where((food) => food.category == _selectedCategory).toList();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('菜品管理'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadFoods,
//             tooltip: '刷新',
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           // Category filter
//           Container(
//             height: 50,
//             margin: EdgeInsets.only(top: 10),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: categories.length,
//               itemBuilder: (ctx, index) {
//                 final category = categories.elementAt(index);
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                   child: ChoiceChip(
//                     label: Text(category),
//                     selected: _selectedCategory == category,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedCategory = category;
//                       });
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Food items list
//           Expanded(
//             child: filteredFoods.isEmpty
//                 ? Center(
//               child: Text(
//                 _selectedCategory == 'All'
//                     ? '还没有添加任何菜品。点击下方按钮添加新菜品。'
//                     : '该类别下没有菜品。',
//                 textAlign: TextAlign.center,
//               ),
//             )
//                 : ListView.builder(
//               itemCount: filteredFoods.length,
//               itemBuilder: (ctx, index) {
//                 final food = filteredFoods[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 8,
//                   ),
//                   child: ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         food.imageUrl,
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                         errorBuilder: (ctx, error, _) => Container(
//                           width: 60,
//                           height: 60,
//                           color: Colors.grey[300],
//                           child: Icon(Icons.image_not_supported),
//                         ),
//                       ),
//                     ),
//                     title: Text(food.name),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           food.description,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '￥${food.price.toStringAsFixed(2)} • ${food.category}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () => _showAddEditFoodDialog(food: food),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _deleteFood(food),
//                         ),
//                       ],
//                     ),
//                     isThreeLine: true,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddEditFoodDialog(),
//         child: Icon(Icons.add),
//         tooltip: '添加新菜品',
//       ),
//     );
//   }
// }