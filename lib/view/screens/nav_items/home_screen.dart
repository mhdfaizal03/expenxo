import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/screens/income_n_expense/add_expense.dart';
import 'package:expenxo/view/screens/income_n_expense/add_income_page.dart';
import 'package:expenxo/view/screens/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return StreamBuilder<List<TransactionModel>>(
      stream: firestoreService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];

        // Calculate Totals
        double totalIncome = 0;
        double totalExpense = 0;
        Map<String, double> expenseCategories = {};

        for (var t in transactions) {
          if (t.type == 'Income') {
            totalIncome += t.amount;
          } else {
            totalExpense += t.amount;
            expenseCategories[t.category] =
                (expenseCategories[t.category] ?? 0) + t.amount;
          }
        }

        final currentBalance = totalIncome - totalExpense;
        final prefs = Provider.of<PreferencesProvider>(context);
        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: prefs.currencySymbol,
          decimalDigits: 0,
        );

        // Find Latest Transactions
        transactions.sort((a, b) => b.date.compareTo(a.date));
        TransactionModel? lastIncome;
        TransactionModel? lastExpense;

        for (var t in transactions) {
          if (t.type == 'Income' && lastIncome == null) {
            lastIncome = t;
          } else if (t.type == 'Expense' && lastExpense == null) {
            lastExpense = t;
          }
          if (lastIncome != null && lastExpense != null) break;
        }

        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15,
                  ),
                  child: Container(
                    height: 40,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expenxo',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Flex(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    direction: Axis.vertical,
                    children: [
                      // Use FutureBuilder to fetch user name from Firestore
                      FutureBuilder<String>(
                        future: firestoreService.getUserName(),
                        builder: (context, userSnapshot) {
                          final displayName =
                              userSnapshot.data?.split(' ').first ?? '....';
                          return Text(
                            'Hello! $displayName...',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Current Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF68B96E), Color(0xFFB8AA6E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(currentBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Monthly Overview Card
                      _buildSectionCard(
                        context: context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monthly Overview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildOverviewRow(
                              context,
                              Icons.radio_button_checked,
                              'Income',
                              currencyFormat.format(totalIncome),
                              Theme.of(context).textTheme.bodyLarge?.color ??
                                  Colors.black,
                            ),
                            const SizedBox(height: 12),
                            _buildOverviewRow(
                              context,
                              Icons.remove_circle_outline,
                              'Expenses',
                              currencyFormat.format(totalExpense),
                              Colors.redAccent,
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: totalIncome > 0
                                  ? (totalExpense / totalIncome).clamp(0.0, 1.0)
                                  : 0,
                              backgroundColor: const Color(0xFFE0F7F3),
                              color: const Color(0xFF00C9A7),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              totalIncome > 0
                                  ? "You've spent ${(totalExpense / totalIncome * 100).toStringAsFixed(0)}% of your income."
                                  : "No income recorded.",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Add Expense',
                              color: const Color(0xFFF25C54),
                              icon: Icons.remove_circle_outline,
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddExpensePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddIncomePage(),
                                  ),
                                );
                              },
                              label: 'Add Income',
                              color: AppColors.mainColor,
                              icon: Icons.add_circle_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Latest Transactions Section
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (lastExpense == null && lastIncome == null)
                        const Text(
                          "No transactions yet",
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        SizedBox(
                          height: 180, // Constrained height for cards
                          child: Row(
                            children: [
                              if (lastExpense != null)
                                Expanded(
                                  child: _buildCategoryCard(
                                    context,
                                    lastExpense.title.isNotEmpty
                                        ? lastExpense.title
                                        : lastExpense.category,
                                    currencyFormat.format(lastExpense.amount),
                                    Icons.money_off,
                                    const Color(0xFFF25C54),
                                    "Latest Expense",
                                  ),
                                ),
                              if (lastExpense != null && lastIncome != null)
                                const SizedBox(width: 16),
                              if (lastIncome != null)
                                Expanded(
                                  child: _buildCategoryCard(
                                    context,
                                    lastIncome.title.isNotEmpty
                                        ? lastIncome.title
                                        : lastIncome.category,
                                    currencyFormat.format(lastIncome.amount),
                                    Icons.attach_money,
                                    AppColors.mainColor,
                                    "Latest Income",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 15),

                      // AI Insights (Static for now, could be dynamic logic)
                      _buildSectionCard(
                        context: context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AI Insights',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Spending tracked via Firebase!',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'View Details & Take Action',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  // UI Helpers
  Widget _buildSectionCard({
    required Widget child,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: child,
    );
  }

  Widget _buildOverviewRow(
    BuildContext context,
    IconData icon,
    String label,
    String amount,
    Color amountColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: label == 'Income'
              ? Theme.of(context).iconTheme.color
              : Colors.redAccent,
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(fontWeight: FontWeight.bold, color: amountColor),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    Function()? onPress,
  }) {
    return ElevatedButton.icon(
      onPressed: onPress,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color graphColor, [
    String? label,
  ]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Use spaceBetween instead of Spacer
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label,
                  style: TextStyle(
                    color: graphColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 24, color: graphColor),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Placeholder for the Sparkline graph (pushed to bottom)
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: graphColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.show_chart, color: graphColor),
          ),
        ],
      ),
    );
  }
}
