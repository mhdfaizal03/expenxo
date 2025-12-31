import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/screens/categories_page.dart';
import 'package:expenxo/view/screens/nav_items/add_budget_page.dart';
import 'package:flutter/material.dart';

class BudgetPlannerPage extends StatelessWidget {
  const BudgetPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10,
                ),
                child: Container(
                  height: 40,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget Planner',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoriesPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 1. Overall Budget Overview Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 24),

                    const Text(
                      'Category Budgets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Category List
                    _buildCategoryBudget(
                      icon: Icons.shopping_basket_outlined,
                      title: "Groceries",
                      allocated: "400.00",
                      spent: "380.00",
                      progress: 0.95,
                    ),
                    _buildCategoryBudget(
                      icon: Icons.restaurant,
                      title: "Dining Out",
                      allocated: "300.00",
                      spent: "320.00",
                      progress: 1.0,
                      color: Colors.red,
                      isOverBudget: true,
                    ),
                    _buildCategoryBudget(
                      icon: Icons.directions_car_outlined,
                      title: "Transportation",
                      allocated: "250.00",
                      spent: "210.00",
                      progress: 0.84,
                    ),
                    _buildCategoryBudget(
                      icon: Icons.home_outlined,
                      title: "Housing",
                      allocated: "800.00",
                      spent: "800.00",
                      progress: 1.0,
                    ),
                    _buildCategoryBudget(
                      icon: Icons.wb_incandescent_outlined,
                      title: "Utilities",
                      allocated: "150.00",
                      spent: "145.00",
                      progress: 0.96,
                    ),
                    _buildCategoryBudget(
                      icon: Icons.favorite_border,
                      title: "Health & Wellness",
                      allocated: "200.00",
                      spent: "110.00",
                      progress: 0.55,
                    ),
                    _buildCategoryBudget(
                      icon: Icons.directions_run_outlined,
                      title: "Entertainment",
                      allocated: "100.00",
                      spent: "120.00",
                      progress: 1.0,
                      color: Colors.red,
                      isOverBudget: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(50),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBudgetPage()),
            );
          },
          backgroundColor: const Color(0xFF00C9A7),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // UI Helper: Top Overview Card
  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "October 2023 Budget Overview",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spent", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                "Remaining",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              backgroundColor: Color(0xFFE0F7F3),
              color: Color(0xFF00C9A7),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹2500.00",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "₹349.50",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF00C9A7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Total Budget | Spent: ₹2150.50",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // UI Helper: Individual Category Row
  Widget _buildCategoryBudget({
    required IconData icon,
    required String title,
    required String allocated,
    required String spent,
    required double progress,
    bool isOverBudget = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black87),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                "Allocated: ₹$allocated",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Spent",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "₹$spent",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? const Color(0xFFF25C54) : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0F7F3),
              color: color ?? AppColors.mainColor,
            ),
          ),
          if (isOverBudget) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF25C54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Over Budget",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
