import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/screens/income_n_expense/add_expense.dart';
import 'package:expenxo/view/screens/income_n_expense/add_income_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                        onPressed: () {},
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
                  const Text(
                    'Hello, Alex!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹25,000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'As of Today',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Overview Card
                  _buildSectionCard(
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
                          Icons.radio_button_checked,
                          'Income',
                          '₹25,000.00',
                          Colors.black,
                        ),
                        const SizedBox(height: 12),
                        _buildOverviewRow(
                          Icons.remove_circle_outline,
                          'Expenses',
                          '₹24,500.00',
                          Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: const Color(0xFFE0F7F3),
                          color: const Color(0xFF00C9A7),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "You've spent 50% of your income this month.",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
                                builder: (context) => AddExpensePage(),
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
                                builder: (context) => AddIncomePage(),
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

                  // Expense Categories
                  const Text(
                    'Expense Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: Row(
                      // scrollDirection: Axis.horizontal,
                      children: [
                        Expanded(
                          child: _buildCategoryCard(
                            'Food',
                            '₹5280.00',
                            Icons.restaurant,
                            Colors.redAccent,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildCategoryCard(
                            'Transport',
                            '₹1400.00',
                            Icons.directions_car_outlined,
                            Colors.deepPurpleAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // AI Insights
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.black,
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
                        const Text(
                          'You spent 15% more on dining this month compared to last. Consider setting a budget for restaurant visits!',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            'View Details & Take Action',
                            style: TextStyle(
                              color: Colors.black,
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
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // UI Helpers
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: child,
    );
  }

  Widget _buildOverviewRow(
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
          color: amountColor == Colors.black ? Colors.black : Colors.redAccent,
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
    String title,
    String amount,
    IconData icon,
    Color graphColor,
  ) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Placeholder for the Sparkline graph
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://placehold.jp/24/${graphColor.value.toRadixString(16).substring(2)}/ffffff/150x50.png?text=Graph',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
