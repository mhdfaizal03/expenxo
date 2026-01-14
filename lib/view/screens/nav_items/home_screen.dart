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

import 'package:expenxo/utils/ui/ui_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Date Filter State
  String _dateFilter = 'This Month'; // Default to Month for Dashboard
  final List<String> _dateOptions = [
    'Today',
    'Week',
    'This Month',
    'Year',
    'All Time',
    'By Date',
    'Custom Range',
  ];
  DateTime? _selectedDate;
  DateTimeRange? _selectedRange;

  // Date Selection Helpers
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.mainColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.mainColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  bool _matchesFilter(TransactionModel transaction) {
    if (_dateFilter == 'All Time') return true;

    final date = transaction.date;
    final now = DateTime.now();

    if (_dateFilter == 'Today') {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } else if (_dateFilter == 'Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final start = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final end = DateTime(
        endOfWeek.year,
        endOfWeek.month,
        endOfWeek.day,
        23,
        59,
        59,
      );

      return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          date.isBefore(end.add(const Duration(milliseconds: 1)));
    } else if (_dateFilter == 'Month') {
      return date.year == now.year && date.month == now.month;
    } else if (_dateFilter == 'Year') {
      return date.year == now.year;
    } else if (_dateFilter == 'By Date' && _selectedDate != null) {
      return date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
    } else if (_dateFilter == 'Custom Range' && _selectedRange != null) {
      final start = DateTime(
        _selectedRange!.start.year,
        _selectedRange!.start.month,
        _selectedRange!.start.day,
      );
      final end = DateTime(
        _selectedRange!.end.year,
        _selectedRange!.end.month,
        _selectedRange!.end.day,
        23,
        59,
        59,
      );

      return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
          date.isBefore(end.add(const Duration(milliseconds: 1)));
    }

    return true;
  }

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

        final prefs = Provider.of<PreferencesProvider>(context);
        var allTransactions = snapshot.data ?? [];

        // Apply Premium Filter
        if (!prefs.isPremium) {
          allTransactions = allTransactions.where((t) => !t.isSms).toList();
        }

        // Apply Date Filter
        final transactions = allTransactions.where(_matchesFilter).toList();

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
        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: prefs.currencySymbol,
          decimalDigits: 0,
        );

        // Find Latest Transactions (Global Latest for sync, but showing filtered list's latest might be more intuitive)
        // Let's show filtered latest as it feels more responsive to the filter.
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              );
                            },
                          ),

                          if (_dateFilter == 'By Date' && _selectedDate != null)
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('MMM dd').format(_selectedDate!),
                                  style: TextStyle(
                                    color: AppColors.mainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          else if (_dateFilter == 'Custom Range' &&
                              _selectedRange != null)
                            GestureDetector(
                              onTap: () => _selectDateRange(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${DateFormat('MMM dd').format(_selectedRange!.start)} - ${DateFormat('MMM dd').format(_selectedRange!.end)}",
                                  style: TextStyle(
                                    color: AppColors.mainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Filter Dropdown
                      Container(
                        height: 45,
                        width: double.infinity,
                        child: PremiumDropdown<String>(
                          value: _dateFilter,
                          icon: Icons.calendar_today_rounded,
                          items: _dateOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontWeight: _dateFilter == value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _dateFilter == value
                                      ? AppColors.mainColor
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) async {
                            if (newValue != null) {
                              setState(() => _dateFilter = newValue);
                              if (newValue == 'By Date') {
                                await _selectDate(context);
                              } else if (newValue == 'Custom Range') {
                                await _selectDateRange(context);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

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
                            Text(
                              'Balance - $_dateFilter',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
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
                              'Available for this period',
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
                            Text(
                              '$_dateFilter Overview',
                              style: const TextStyle(
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
                                  : "No income for this period.",
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
                      Text(
                        'Recent Activity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (lastExpense == null && lastIncome == null)
                        const Text(
                          "No transactions for this period",
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
