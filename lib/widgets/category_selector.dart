// 优化首页中的分类选择器
// screens/home/category_selector.dart

import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> _categories = [
      'All',
      'Malaysian',
      'Chinese',
      'Indian',
      'Fast Food',
      'Desserts',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              // 调用外部传入的回调函数而不是内部 setState
              onCategorySelected(category);
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