import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // Dropdown initial values
  String selectedCategory = 'Food & Dining';
  String selectedPayment = 'Credit Card';
  DateTime selectedDate = DateTime(2025, 12, 28);

  @override
  Widget build(BuildContext context) {
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
          'Add Expense',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Field
            _buildLabel("Amount"),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("").copyWith(
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '₹',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                hintText: "50.00",
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            _buildLabel("Category"),
            _buildDropdown(
              value: selectedCategory,
              items: [
                'Food & Dining',
                'Transport',
                'Shopping',
                'Entertainment',
              ],
              onChanged: (val) => setState(() => selectedCategory = val!),
            ),
            const SizedBox(height: 20),

            // Date Picker
            _buildLabel("Date"),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) setState(() => selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: _containerDecoration(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 12),
                    Text("Dec 28, 2025", style: const TextStyle(fontSize: 15)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Method Dropdown
            _buildLabel("Payment Method"),
            _buildDropdown(
              icon: Icons.account_balance_wallet_outlined,
              value: selectedPayment,
              items: ['Credit Card', 'Debit Card', 'Cash', 'UPI'],
              onChanged: (val) => setState(() => selectedPayment = val!),
            ),
            const SizedBox(height: 20),

            // Notes Field
            _buildLabel("Notes"),
            TextField(
              maxLines: 4,
              decoration: _inputDecoration(
                "Add a brief description or note...",
              ),
            ),
            const SizedBox(height: 20),

            // Receipt Upload
            _buildLabel("Receipt"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  style: BorderStyle.solid,
                ),
              ),
              child: InkWell(
                onTap: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Colors.black54),
                    SizedBox(width: 8),
                    Text(
                      "Upload Receipt Image",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C9A7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save Expense',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00C9A7)),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _containerDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(item, style: const TextStyle(fontSize: 15)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
