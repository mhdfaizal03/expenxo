import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/utils/ui/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedFilter = 'All Time';
  final List<String> _filters = [
    'Today',
    'Week',
    'Month',
    'Year',
    'By Date',
    'Custom Range',
    'All Time',
  ];

  DateTime? _selectedDate;
  DateTimeRange? _selectedRange;

  List<TransactionModel> _filterTransactions(List<TransactionModel> all) {
    final now = DateTime.now();
    return all.where((t) {
      final date = t.date;
      if (_selectedFilter == 'All Time') return true;

      if (_selectedFilter == 'Today') {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      } else if (_selectedFilter == 'Week') {
        // Simple "Current Week" (Mon-Sun could be better, but last 7 days is also common. Let's do 'Same Week')
        // Or "Last 7 Days". Let's stick to "This Week" (Monday start)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        // Normalize to start of days
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
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      } else if (_selectedFilter == 'Month') {
        return date.year == now.year && date.month == now.month;
      } else if (_selectedFilter == 'Year') {
        return date.year == now.year;
      } else if (_selectedFilter == 'By Date' && _selectedDate != null) {
        return date.year == _selectedDate!.year &&
            date.month == _selectedDate!.month &&
            date.day == _selectedDate!.day;
      } else if (_selectedFilter == 'Custom Range' && _selectedRange != null) {
        return date.isAfter(
              _selectedRange!.start.subtract(const Duration(seconds: 1)),
            ) &&
            date.isBefore(
              _selectedRange!.end.add(const Duration(days: 1)),
            ); // Include end date fully
      }
      return true;
    }).toList();
  }

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

        final transactions = _filterTransactions(allTransactions);

        // --- Data Aggregation Logic ---

        // 1. Overview Stats (Total for Filter)
        double totalIncome = 0;
        double totalExpense = 0;
        Map<String, double> categoryExpenses = {};

        // Data for Bar Chart
        // Dynamic Key: Hour (Today), Day (Week/Month), Month (Year/All Time)
        Map<int, Map<String, double>> chartData = {};

        for (var t in transactions) {
          if (t.type == 'Income') {
            totalIncome += t.amount;
          } else {
            totalExpense += t.amount;
            categoryExpenses[t.category] =
                (categoryExpenses[t.category] ?? 0) + t.amount;
          }

          int key;
          // Determine key based on filter
          if (_selectedFilter == 'Today' || _selectedFilter == 'By Date') {
            key = t.date.hour; // 0-23
          } else if (_selectedFilter == 'Week') {
            key = t.date.weekday; // 1-7
          } else if (_selectedFilter == 'Month') {
            key = t.date.day; // 1-31
          } else if (_selectedFilter == 'Custom Range') {
            // If range > 2 months, show months, else show days
            final days = _selectedRange != null
                ? _selectedRange!.duration.inDays
                : 0;
            if (days > 60) {
              key = t.date.month - 1;
            } else {
              // For daily in range, we might need a mapping.
              // Simplest for this chart widget: just use day of month if within same month,
              // but that breaks across months.
              // Let's use 'day of year' for uniqueness or simple Mapping?
              // The _BarChartWidget expects 0..N int keys.
              // Let's stick to Day of Month for now if < 31 days range?
              // Or simpler: Just calculate offset from start date?
              if (_selectedRange != null) {
                key = t.date.difference(_selectedRange!.start).inDays;
              } else {
                key = t.date.day;
              }
            }
          } else {
            key = t.date.month - 1; // 0-11
          }

          if (!chartData.containsKey(key)) {
            chartData[key] = {'Income': 0.0, 'Expense': 0.0};
          }
          if (t.type == 'Income') {
            chartData[key]!['Income'] =
                (chartData[key]!['Income'] ?? 0) + t.amount;
          } else {
            chartData[key]!['Expense'] =
                (chartData[key]!['Expense'] ?? 0) + t.amount;
          }
        }

        double netSavings = totalIncome - totalExpense;
        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: prefs.currencySymbol,
          decimalDigits: 0,
        );

        // Prepare Pie Chart Sections
        List<PieChartSectionData> pieSections = [];
        final List<Color> palette = [
          const Color(0xFFE76F51),
          const Color(0xFF2A9D8F),
          const Color(0xFF264653),
          const Color(0xFFE9C46A),
          const Color(0xFFF4A261),
          Colors.blueAccent,
          Colors.purpleAccent,
        ];

        int colorIndex = 0;
        categoryExpenses.forEach((category, amount) {
          final percentage = totalExpense > 0
              ? (amount / totalExpense) * 100
              : 0.0;
          pieSections.add(
            PieChartSectionData(
              color: palette[colorIndex % palette.length],
              value: percentage,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 80,
              showTitle: true,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
          colorIndex++;
        });

        if (pieSections.isEmpty && totalExpense == 0) {
          pieSections.add(
            PieChartSectionData(
              color: Colors.grey[300],
              value: 100,
              radius: 80,
              showTitle: false,
            ),
          );
        }

        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10,
                  ),
                  child: Container(
                    height: 48,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Analytics',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.color,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: PremiumDropdown<String>(
                              value: _selectedFilter,
                              icon: Icons.filter_list_rounded,
                              items: _filters.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                if (newValue != null) {
                                  setState(() => _selectedFilter = newValue);
                                  if (newValue == 'By Date') {
                                    await _selectDate(context);
                                  } else if (newValue == 'Custom Range') {
                                    await _selectDateRange(context);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Date Display for custom filters
                if (_selectedFilter == 'By Date' && _selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Text(
                        DateFormat('EEE, MMM dd, yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_selectedFilter == 'Custom Range' && _selectedRange != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _selectDateRange(context),
                      child: Text(
                        "${DateFormat('MMM dd').format(_selectedRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedRange!.end)}",
                        style: TextStyle(
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // 1. Spending by Category (Pie Chart)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      _buildReportCard(
                        context: context,
                        title: "Spending by Category",
                        subtitle: _selectedFilter,
                        child: Column(
                          children: [
                            if (totalExpense == 0)
                              const SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text("No expenses for this period"),
                                ),
                              )
                            else ...[
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 0,
                                    sections: pieSections,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Simple Legend (Dynamic)
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: categoryExpenses.keys.map((cat) {
                                  int idx = categoryExpenses.keys
                                      .toList()
                                      .indexOf(cat);
                                  return _indicator(
                                    palette[idx % palette.length],
                                    cat,
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Trend (Bar Chart)
                      _buildReportCard(
                        context: context,
                        title: "Financial Trend",
                        subtitle: _getChartSubtitle(),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: _BarChartWidget(
                                chartData: chartData,
                                filter: _selectedFilter,
                                customRange: _selectedRange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _indicator(AppColors.mainColor, "Income"),
                                const SizedBox(width: 20),
                                _indicator(const Color(0xFFF25C54), "Expenses"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Overview Summary
                      _buildReportCard(
                        context: context,
                        title: "Overview",
                        subtitle: _selectedFilter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem(
                              "Income",
                              currencyFormat.format(totalIncome),
                              AppColors.mainColor,
                              Icons.arrow_upward,
                            ),
                            _statItem(
                              "Expenses",
                              currencyFormat.format(totalExpense),
                              const Color(0xFFF25C54),
                              Icons.arrow_downward,
                            ),
                            _statItem(
                              "Savings",
                              currencyFormat.format(netSavings),
                              netSavings >= 0
                                  ? AppColors.mainColor
                                  : Colors.red,
                              Icons.savings_outlined,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. AI Insights Box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.mainColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.mainColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "AI Insights",
                                  style: TextStyle(
                                    color: AppColors.mainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              netSavings > 0
                                  ? "Good job! You saved ${currencyFormat.format(netSavings)} this period."
                                  : "Your expenses exceeded income by ${currencyFormat.format(netSavings.abs())}.",
                              style: TextStyle(
                                color: AppColors.mainColor,
                                height: 1.5,
                                fontSize: 14,
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

  String _getChartSubtitle() {
    if (_selectedFilter == 'Today' || _selectedFilter == 'By Date')
      return 'Hourly breakdown';
    if (_selectedFilter == 'Week') return 'Daily breakdown';
    if (_selectedFilter == 'Month') return 'Day-by-day';
    if (_selectedFilter == 'Custom Range') return 'Daily Trend';
    return 'Monthly breakdown';
  }

  // UI Helpers
  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _statItem(String label, String amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final Map<int, Map<String, double>> chartData;
  final String filter;
  final DateTimeRange? customRange;

  const _BarChartWidget({
    required this.chartData,
    required this.filter,
    this.customRange,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(0),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _getTitle(index),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ), // Hide Left Titles for cleaner look
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _getBarGroups(),
      ),
    );
  }

  String _getTitle(int index) {
    if (filter == 'Today' || filter == 'By Date') {
      // Just show every 4 hours to avoid overcrowding or specific hours
      if (index % 4 == 0) return '${index}h';
      return '';
    } else if (filter == 'Week') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (index >= 1 && index <= 7) return days[index - 1];
      return '';
    } else if (filter == 'Month') {
      // Show every 5th day
      if (index % 5 == 0 || index == 1) return index.toString();
      return '';
    } else if (filter == 'Custom Range' && customRange != null) {
      // If viewing by offset days
      final date = customRange!.start.add(Duration(days: index));
      // Show date if it fits. E.g. every 3rd day?
      if (customRange!.duration.inDays > 10) {
        if (index % 5 == 0) return DateFormat('dd/MM').format(date);
      } else {
        return DateFormat('E').format(date);
      }
      return '';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      if (index >= 0 && index < 12) return months[index];
      return '';
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> groups = [];

    // Determine range based on filter
    int start = 0;
    int end = 0;

    if (filter == 'Today' || filter == 'By Date') {
      start = 0;
      end = 23;
    } else if (filter == 'Week') {
      start = 1;
      end = 7;
    } else if (filter == 'Month') {
      start = 1;
      end = 31;
    } else if (filter == 'Custom Range') {
      if (customRange != null) {
        start = 0;
        end = customRange!.duration.inDays; // includes last day
      }
    } else {
      start = 0;
      end = 11;
    }

    for (int i = start; i <= end; i++) {
      // Only add group if we want to show empty bars or just relevant ones.
      // For BarChart to look correct on X axis, we usually need all x values if we use specific titles mapping.
      // Or we can just map existing data.
      // Let's populate all for continuous axis feel.

      final data = chartData[i];
      final income = data?['Income'] ?? 0;
      final expense = data?['Expense'] ?? 0;

      // Skip completely empty stats? maybe not, better to show zero gaps

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: AppColors.mainColor,
              width: 6, // Thinner bars for month view
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: expense,
              color: const Color(0xFFF25C54),
              width: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  double _getMaxY() {
    double max = 100; // default min height
    chartData.forEach((key, value) {
      if ((value['Income'] ?? 0) > max) max = value['Income']!;
      if ((value['Expense'] ?? 0) > max) max = value['Expense']!;
    });
    return max * 1.2; // Add some buffer
  }
}
