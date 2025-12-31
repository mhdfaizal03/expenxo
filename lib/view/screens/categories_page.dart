import 'package:expenxo/view/screens/add_categories_page.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data list representing the categories in the image
    final List<Map<String, dynamic>> categories = [
      {'name': 'Food & Dining', 'icon': Icons.restaurant},
      {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
      {'name': 'Home & Utilities', 'icon': Icons.home_outlined},
      {'name': 'Transportation', 'icon': Icons.directions_car_outlined},
      {
        'name': 'Check & Fitness',
        'icon': Icons.check_circle_outline,
        'isSpecial': true,
      },
      {'name': 'Education', 'icon': Icons.school_outlined},
      {'name': 'Entertainment', 'icon': Icons.auto_awesome},
      {'name': 'Clothing', 'icon': Icons.checkroom},
      {'name': 'Gaming', 'icon': Icons.videogame_asset_outlined},
      {
        'name': 'Gifts & Donations',
        'icon': Icons.card_giftcard,
        'isSpecial': true,
      },
      {'name': 'Social Life', 'icon': Icons.handshake_outlined},
      {'name': 'Personal Care', 'icon': Icons.favorite_border},
      {'name': 'Vehicle Maintenance', 'icon': Icons.minor_crash_outlined},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryPage()),
              );
            }, // Add logic for new category
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _buildCategoryTile(
            name: item['name'],
            icon: item['icon'],
            isSpecial: item['isSpecial'] ?? false,
          );
        },
      ),
    );
  }

  Widget _buildCategoryTile({
    required String name,
    required IconData icon,
    bool isSpecial = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Some icons in the image have a light teal circular background
              color: isSpecial ? const Color(0xFFE0F7F3) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSpecial ? const Color(0xFF00C9A7) : Colors.black87,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Category Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          // Action Buttons
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
