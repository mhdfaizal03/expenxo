import 'package:flutter/material.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  // State variables for form fields
  String? selectedSource;
  DateTime selectedDate = DateTime(2025, 12, 28);
  final TextEditingController _amountController = TextEditingController(
    text: "0.00",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Income',
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
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16),
              decoration: _inputDecoration("").copyWith(
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '₹',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Source Selection
            _buildLabel("Source"),
            InkWell(
              onTap: () {
                // Logic to open source selection
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
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedSource ?? "Select income source",
                      style: TextStyle(
                        fontSize: 15,
                        color: selectedSource == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
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
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "December 28th, 2025",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes Field
            _buildLabel("Notes"),
            TextField(
              maxLines: 5,
              decoration: _inputDecoration(
                "Add any additional details or context for this income...",
              ),
            ),
            const SizedBox(height: 40),

            // Save Income Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C9A7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Income',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helper: Standard Label
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

  // UI Helper: Common Container Decoration
  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    );
  }

  // UI Helper: TextField Decoration
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
}
