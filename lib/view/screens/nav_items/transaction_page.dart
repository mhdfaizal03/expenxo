import 'package:expenxo/utils/constands/colors.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Transactions',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: Colors.black),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search transactions...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterChip("Last 30 Days", isSelected: true),
                  _buildFilterChip("Category", icon: Icons.label_outline),
                  _buildFilterChip("Type", icon: Icons.list),
                  _buildFilterChip(
                    "Bank",
                    icon: Icons.account_balance_outlined,
                  ),
                ],
              ),
            ),

            // Transaction List
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  _transactionItem(
                    "Food & Dining",
                    "Dinner at Italian restaurant",
                    "Oct 26, 2023",
                    "-₹5280.50",
                    Icons.restaurant,
                    Colors.redAccent,
                  ),
                  _transactionItem(
                    "Salary",
                    "Monthly paycheck",
                    "Oct 25, 2023",
                    "+₹2500.00",
                    Icons.payments_outlined,
                    const Color(0xFF00C9A7),
                  ),
                  _transactionItem(
                    "Shopping",
                    "New shoes",
                    "Oct 24, 2023",
                    "-₹1800.00",
                    Icons.shopping_bag_outlined,
                    Colors.redAccent,
                  ),
                  _transactionItem(
                    "Rent",
                    "Monthly apartment rent",
                    "Oct 23, 2023",
                    "-₹3500.00",
                    Icons.home_outlined,
                    Colors.redAccent,
                  ),
                  _transactionItem(
                    "Transportation",
                    "Gas refill",
                    "Oct 22, 2023",
                    "-₹150.00",
                    Icons.directions_car_outlined,
                    Colors.redAccent,
                  ),
                  _transactionItem(
                    "Gift Received",
                    "Birthday gift from parents",
                    "Oct 21, 2023",
                    "+₹100.00",
                    Icons.card_giftcard_outlined,
                    const Color(0xFF00C9A7),
                  ),
                  _transactionItem(
                    "Health",
                    "Pharmacy purchase",
                    "Oct 20, 2023",
                    "-₹22.75",
                    Icons.favorite_outline,
                    Colors.redAccent,
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

  // Filter Chip Builder
  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00C9A7) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Transaction Row Builder
  Widget _transactionItem(
    String title,
    String subtitle,
    String date,
    String amount,
    IconData icon,
    Color amountColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5F5F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          // Amount and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 12),
                  Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
