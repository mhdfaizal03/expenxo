import 'package:flutter/material.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  // State variables
  String categoryName = "Dining Out";
  Color selectedColor = const Color(0xFF8E44AD); // Purple from image
  bool isExpense = true;

  final List<Color> availableColors = [
    const Color(0xFF00C9A7),
    const Color(0xFFFFC107),
    Colors.white,
    Colors.white,
    Colors.white,
    const Color(0xFF00C9A7),
    const Color(0xFFFFC107),
    const Color(0xFFF25C54),
    const Color(0xFF8E44AD),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Category',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Category Name"),
            TextField(
              onChanged: (val) => setState(() => categoryName = val),
              decoration: _inputDecoration("Dining Out"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Select Icon"),
            _buildActionTile(Icons.restaurant, "Change Icon"),
            const SizedBox(height: 8),
            const Text(
              "Choose an icon that best represents your category.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),

            _buildLabel("Category Color"),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...availableColors.map((color) => _buildColorOption(color)),
                _buildAddColorButton(),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel("Category Type"),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            _buildLabel("Default Budget Allocation (Optional)"),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("").copyWith(
                prefixIcon: const Icon(Icons.attach_money, size: 20),
                hintText: "75.00",
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Set a default budget for new transactions in this category.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            _buildLabel("Example Transaction"),
            _buildPreviewCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  // --- UI Components ---

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C9A7)),
    ),
  );

  Widget _buildActionTile(IconData icon, String label) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    ),
  );

  Widget _buildColorOption(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: color == Colors.white
              ? Border.all(color: const Color(0xFFE2E8F0))
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _buildAddColorButton() => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: const Icon(Icons.add, color: Colors.grey, size: 20),
  );

  Widget _buildTypeSelector() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F4F8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: _buildTypeButton("Expense", Icons.trending_down, isExpense),
        ),
        Expanded(
          child: _buildTypeButton("Income", Icons.trending_up, !isExpense),
        ),
      ],
    ),
  );

  Widget _buildTypeButton(String title, IconData icon, bool active) =>
      GestureDetector(
        onTap: () => setState(() => isExpense = title == "Expense"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00C9A7) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? Colors.white : Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPreviewCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF0F0F0)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: Colors.black87),
            ),
            const SizedBox(width: 12),
            const Text(
              "Dining Out",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Merchant",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text("Amount", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Local Cafe", style: TextStyle(fontWeight: FontWeight.w500)),
            Text("-\$35.50", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                "Today, 10:30 AM",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildBottomButtons() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFF25C54)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Color(0xFFF25C54)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C9A7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
