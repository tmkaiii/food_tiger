// 优化首页中的分类选择器
// screens/home/category_selector.dart

import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({Key? key}) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Malaysian',
    'Chinese',
    'Indian',
    'Fast Food',
    'Desserts',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              // 这里可以添加过滤餐厅的逻辑
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                backgroundColor: isSelected
                    ? const Color(0xFF008080)
                    : Colors.grey[200],
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          );
        },
      ),
    );
  }
}