import 'package:expenxo/models/category_model.dart';
import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/utils/ui/ui_helper.dart';
import 'package:expenxo/view/screens/add_categories_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Filter States
  String _searchQuery = "";
  String _selectedFilterMode =
      "All"; // "Category", "Type", (Date is handled by dropdown)

  // Date Filter State
  String _dateFilter = 'All Time';
  final List<String> _dateOptions = [
    'Today',
    'Week',
    'Month',
    'Year',
    'All Time',
    'By Date',
    'Custom Range',
  ];
  DateTime? _selectedDate;
  DateTimeRange? _selectedRange;

  String? _categoryFilter;
  String? _typeFilter;

  // Default Categories & Icons
  final Map<String, IconData> _defaultCategoryIcons = {
    'Food & Dining': Icons.restaurant_menu_rounded,
    'Transport': Icons.directions_car_filled_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Entertainment': Icons.movie_rounded,
    'Health': Icons.medical_services_rounded,
    'Salary': Icons.account_balance_wallet_rounded,
    'Others': Icons.receipt_long_rounded,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  // Icon Lookup Helper
  IconData _getCategoryIcon(
    String categoryName,
    List<CategoryModel> customCategories,
  ) {
    // 1. Check Custom Categories
    try {
      final customCat = customCategories.firstWhere(
        (c) => c.name == categoryName,
      );
      return IconHelper.getIconFromCode(customCat.iconCode);
    } catch (e) {
      // Not found in custom
    }

    // 2. Check Defaults (Partial match for robustness, or exact)
    // We try exact first
    if (_defaultCategoryIcons.containsKey(categoryName)) {
      return _defaultCategoryIcons[categoryName]!;
    }

    // Legacy/Partial Fallback
    if (categoryName.contains("Food")) return Icons.restaurant_menu_rounded;
    if (categoryName.contains("Transport"))
      return Icons.directions_car_filled_rounded;
    if (categoryName.contains("Shopping")) return Icons.shopping_bag_rounded;
    if (categoryName.contains("Salary"))
      return Icons.account_balance_wallet_rounded;
    if (categoryName.contains("Health")) return Icons.medical_services_rounded;
    if (categoryName.contains("Ent")) return Icons.movie_rounded;

    return Icons.receipt_long_rounded; // Fallback
  }

  // Date Selection Helpers
  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.mainColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                    surface: AppColors.cardDark,
                  )
                : ColorScheme.light(
                    primary: AppColors.mainColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
            dialogBackgroundColor: isDark ? AppColors.cardDark : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.mainColor),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: isDark
                ? AppColors.scaffoldDark
                : Colors.white,
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.mainColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                    surface: AppColors.cardDark,
                  )
                : ColorScheme.light(
                    primary: AppColors.mainColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
            dialogBackgroundColor: isDark ? AppColors.cardDark : Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
              iconTheme: IconThemeData(
                color: isDark ? Colors.white : Colors.black,
              ),
              elevation: 0,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.mainColor),
            ),
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

  void _onFilterSelected(String filter) {
    setState(() {
      if (_selectedFilterMode == filter) {
        _selectedFilterMode = "All"; // Toggle off
        _categoryFilter = null;
        _typeFilter = null;
      } else {
        _selectedFilterMode = filter;
        if (filter != 'Category') _categoryFilter = null;
        if (filter != 'Type') _typeFilter = null;
      }
    });

    if (filter == 'Category') {
      _showCategoryFilterDialog();
    } else if (filter == 'Type') {
      _showTypeFilterDialog();
    }
  }

  void _showCategoryFilterDialog() {
    DialogUtils.showPremiumDialog(
      context: context,
      title: "Filter by Category",
      content: StreamBuilder<List<CategoryModel>>(
        stream: Provider.of<FirestoreService>(
          context,
          listen: false,
        ).getCategories(),
        builder: (context, snapshot) {
          // Merge Defaults + Custom
          List<String> allCategories = _defaultCategoryIcons.keys.toList();

          if (snapshot.hasData && snapshot.data != null) {
            final customCategories = snapshot.data!.map((c) => c.name).toList();
            for (var custom in customCategories) {
              if (!allCategories.contains(custom)) {
                allCategories.add(custom);
              }
            }
          }

          allCategories.sort(); // Sort for better UX

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: allCategories.map((cat) {
              final isSelected = _categoryFilter == cat;
              return Tooltip(
                message: cat,
                child: InkWell(
                  onTap: () {
                    setState(() => _categoryFilter = isSelected ? null : cat);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mainColor
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.mainColor
                            : Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.mainColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() => _categoryFilter = null);
            Navigator.pop(context);
          },
          child: const Text(
            "Clear Filter",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  void _showTypeFilterDialog() {
    DialogUtils.showPremiumDialog(
      context: context,
      title: "Transaction Type",
      content: Row(
        children: [
          Expanded(
            child: _buildNewTypeCard(
              "Income",
              Icons.arrow_downward_rounded,
              const Color(0xFF00C9A7),
              _typeFilter == "Income",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildNewTypeCard(
              "Expense",
              Icons.arrow_upward_rounded,
              Colors.redAccent,
              _typeFilter == "Expense",
            ),
          ),
        ],
      ),
      actions: [
        if (_typeFilter != null)
          TextButton(
            onPressed: () {
              setState(() => _typeFilter = null);
              Navigator.pop(context);
            },
            child: const Text(
              "Clear Filter",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildNewTypeCard(
    String type,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _typeFilter = isSelected ? null : type);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              type,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(TransactionModel transaction) {
    // 1. Search Query
    if (_searchQuery.isNotEmpty) {
      bool matches = false;
      matches =
          transaction.title.toLowerCase().contains(_searchQuery) ||
          transaction.category.toLowerCase().contains(_searchQuery) ||
          transaction.description.toLowerCase().contains(_searchQuery);
      if (!matches) return false;
    }

    // 2. Chip Filters (Category & Type)
    if (_selectedFilterMode == "Category" && _categoryFilter != null) {
      if (transaction.category != _categoryFilter &&
          !transaction.category.contains(_categoryFilter!))
        return false;
    }

    if (_selectedFilterMode == "Type" && _typeFilter != null) {
      if (transaction.type != _typeFilter) return false;
    }

    // 3. Date Filter
    if (_dateFilter == 'All Time') return true;

    final date = transaction.date;
    final now = DateTime.now();

    if (_dateFilter == 'Today') {
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } else if (_dateFilter == 'Week') {
      // Logic for current week (Mon-Sun generally, or generic 7 days)
      // Usually "Week" implies "This Week"
      // Getting start of week (assuming Monday start)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Reset time components for accurate comparison
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

      // Use inclusive check
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
    final prefs = Provider.of<PreferencesProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: prefs.currencySymbol,
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15,
                ),
                child: SizedBox(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.color,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCategoryPage(),
                                  ),
                                );
                              },

                              child: Text(
                                "Add Category",
                                style: TextStyle(
                                  color: AppColors.mainColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_dateFilter == 'By Date' &&
                                _selectedDate != null)
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
                                    DateFormat(
                                      'EEE, MMM dd, yyyy',
                                    ).format(_selectedDate!),
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
                                    "${DateFormat('MMM dd').format(_selectedRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedRange!.end)}",
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
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                              : Theme.of(context).textTheme.bodyLarge?.color,
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

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search transactions...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 24,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.mainColor,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildFilterChip(
                      "Category",
                      icon: Icons.sell_outlined,
                      subtitle: _categoryFilter,
                    ),
                    _buildFilterChip(
                      "Type",
                      icon: Icons.filter_list_rounded,
                      subtitle: _typeFilter,
                    ),
                  ],
                ),
              ),

              // Transaction List with Categories Stream
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: StreamBuilder<List<CategoryModel>>(
                  stream: firestoreService.getCategories(), // Fetch Categories
                  builder: (context, categorySnapshot) {
                    List<CategoryModel> customCategories = [];
                    if (categorySnapshot.hasData) {
                      customCategories = categorySnapshot.data!;
                    }

                    return StreamBuilder<List<TransactionModel>>(
                      stream: firestoreService
                          .getTransactions(), // Fetch Transactions
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 60),
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No transactions yet",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          );
                        }

                        final allTransactions = snapshot.data!;
                        final filteredTransactions = allTransactions.where((t) {
                          // Filter out SMS transactions if not premium
                          if (!prefs.isPremium && t.isSms) return false;
                          return _matchesFilter(t);
                        }).toList();

                        if (filteredTransactions.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 60),
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No matching transactions",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          );
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 900) {
                              // Desktop Grid Layout
                              return Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                children: filteredTransactions.map((
                                  transaction,
                                ) {
                                  return SizedBox(
                                    width:
                                        (constraints.maxWidth - 40) /
                                        2, // 2 columns
                                    child: _transactionItem(
                                      context,
                                      transaction,
                                      currencyFormat,
                                      dateFormat,
                                      customCategories,
                                    ),
                                  );
                                }).toList(),
                              );
                            } else {
                              // Mobile List Layout
                              return Column(
                                children: filteredTransactions.map((
                                  transaction,
                                ) {
                                  return _transactionItem(
                                    context,
                                    transaction,
                                    currencyFormat,
                                    dateFormat,
                                    customCategories,
                                  );
                                }).toList(),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Filter Chip Builder
  Widget _buildFilterChip(String label, {IconData? icon, String? subtitle}) {
    bool isSelected = false;
    if (label == "Category")
      isSelected = _selectedFilterMode == "Category" || _categoryFilter != null;
    else if (label == "Type")
      isSelected = _selectedFilterMode == "Type" || _typeFilter != null;

    String displayText = (subtitle != null) ? subtitle : label;

    return GestureDetector(
      onTap: () => _onFilterSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.mainColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              displayText,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.close_rounded,
                size: 14,
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Transaction Row Builder
  Widget _transactionItem(
    BuildContext context,
    TransactionModel transaction,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
    List<CategoryModel> customCategories,
  ) {
    final isIncome = transaction.type == 'Income';
    final amountColor = isIncome
        ? const Color(0xFF00C9A7)
        : const Color(0xFFFF5252);
    final prefix = isIncome ? "+" : "-";

    // Dynamic Icon Lookup
    IconData icon = _getCategoryIcon(transaction.category, customCategories);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.blueGrey.shade300, size: 24),
          ),
          const SizedBox(width: 18),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title.isNotEmpty
                      ? transaction.title
                      : transaction.category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                if (transaction.description.isNotEmpty)
                  Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(transaction.date),
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ),
          // Amount and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$prefix${currencyFormat.format(transaction.amount)}",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Delete Action
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        bool? confirm = await DialogUtils.showConfirmDialog(
                          context: context,
                          title: "Delete Transaction?",
                          message:
                              "This transaction will be permanently removed. This action cannot be undone.",
                          isDestructive: true,
                          confirmLabel: "Delete",
                        );

                        if (confirm == true) {
                          await Provider.of<FirestoreService>(
                            context,
                            listen: false,
                          ).deleteTransaction(transaction.id);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.redAccent.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
