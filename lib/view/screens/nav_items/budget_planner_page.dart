import 'package:expenxo/models/budget_model.dart';
import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/ui/ui_helper.dart';
import 'package:expenxo/utils/constands/colors.dart';

import 'package:expenxo/view/screens/nav_items/add_budget_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expenxo/providers/preferences_provider.dart';

class BudgetPlannerPage extends StatelessWidget {
  const BudgetPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final prefs = Provider.of<PreferencesProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: prefs.currencySymbol,
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: StreamBuilder<List<BudgetModel>>(
            stream: firestoreService.getBudgets(),
            builder: (context, budgetSnapshot) {
              if (budgetSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final budgets = budgetSnapshot.data ?? [];

              return StreamBuilder<List<TransactionModel>>(
                stream: firestoreService.getTransactions(),
                builder: (context, transactionSnapshot) {
                  if (transactionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(),
                    ); // Budgets loading handles spinner
                  }

                  final transactions = transactionSnapshot.data ?? [];

                  // Logic: Calculate Total Budget, Total Spent, and budget per category
                  double totalBudget = 0;
                  double totalSpent = 0;

                  // Map to hold spent per category
                  Map<String, double> categorySpent = {};

                  // Initialize from budgets
                  for (var b in budgets) {
                    totalBudget += b.amount;
                    categorySpent[b.category] = 0;
                  }

                  // Sum up transactions that fall within budget periods
                  // For simplicity in this overview, we sum up current month expenses for comparison
                  // Or refined: Check if transaction date is within budget start/end

                  for (var t in transactions) {
                    if (t.type == 'Expense') {
                      // Find matching budget for this transaction
                      // Simple matching by category and date range
                      // If no budget exists, we can track it as "Unbudgeted" or ignore for "Budget Planner" view

                      for (var b in budgets) {
                        if ((t.category == b.category ||
                                t.title == b.category) &&
                            t.date.isAfter(b.startDate) &&
                            t.date.isBefore(b.endDate)) {
                          categorySpent[b.category] =
                              (categorySpent[b.category] ?? 0) + t.amount;
                          totalSpent += t.amount;
                        }
                      }
                    }
                  }

                  double totalProgress = totalBudget > 0
                      ? (totalSpent / totalBudget)
                      : 0;
                  double remaining = totalBudget - totalSpent;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10,
                        ),
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Budget Planner',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.color,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 1. Overall Budget Overview Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverviewCard(
                              context,
                              totalSpent,
                              totalBudget,
                              remaining,
                              totalProgress,
                              currencyFormat,
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'Category Budgets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Category List from Budgets
                            if (budgets.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Center(
                                  child: Text(
                                    "No budgets set yet. Tap + to add one.",
                                  ),
                                ),
                              )
                            else
                              ...budgets.map((budget) {
                                double spent =
                                    categorySpent[budget.category] ?? 0;
                                double progress = budget.amount > 0
                                    ? spent / budget.amount
                                    : 0;
                                bool isOver = spent > budget.amount;

                                IconData icon = Icons.category_outlined;
                                if (budget.category.contains('Food'))
                                  icon = Icons.restaurant;
                                else if (budget.category.contains('Transport'))
                                  icon = Icons.directions_car_outlined;
                                else if (budget.category.contains('Shopping'))
                                  icon = Icons.shopping_bag_outlined;
                                else if (budget.category.contains('Health'))
                                  icon = Icons.favorite_border;
                                else if (budget.category.contains(
                                  'Entertainment',
                                ))
                                  icon = Icons.movie_outlined;
                                else if (budget.category.contains('Utilities'))
                                  icon = Icons.lightbulb_outline;

                                return GestureDetector(
                                  onLongPress: () async {
                                    // Quick Delete
                                    bool?
                                    confirm = await DialogUtils.showConfirmDialog(
                                      context: context,
                                      title: "Delete Budget",
                                      message:
                                          "Are you sure you want to delete the budget for ${budget.category}?",
                                      isDestructive: true,
                                    );
                                    if (confirm == true) {
                                      await Provider.of<FirestoreService>(
                                        context,
                                        listen: false,
                                      ).deleteBudget(budget.id);
                                    }
                                  },
                                  child: _buildCategoryBudget(
                                    context: context,
                                    icon: icon,
                                    title: budget.category,
                                    allocated: currencyFormat.format(
                                      budget.amount,
                                    ),
                                    spent: currencyFormat.format(spent),
                                    progress: progress,
                                    isOverBudget: isOver,
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBudgetPage()),
            );
          },
          backgroundColor: AppColors.mainColor,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // UI Helper: Top Overview Card
  Widget _buildOverviewCard(
    BuildContext context,
    double spent,
    double total,
    double remaining,
    double progress,
    NumberFormat fmt,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overall Budget Status", // Could be dynamic month name
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Spent",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              Text(
                "Remaining",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE0F7F3),
              color: progress > 1 ? Colors.redAccent : AppColors.mainColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fmt.format(spent),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                fmt.format(remaining),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: remaining < 0 ? Colors.redAccent : AppColors.mainColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Total Budget: ${fmt.format(total)}",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // UI Helper: Individual Category Row
  Widget _buildCategoryBudget({
    required BuildContext context,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              Text(
                "Target: $allocated",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Spent",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              Text(
                spent,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOverBudget
                      ? const Color(0xFFF25C54)
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              minHeight: 6,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
              color: isOverBudget
                  ? const Color(0xFFF25C54)
                  : (color ?? AppColors.mainColor),
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
