import 'package:flutter/material.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  // State for Selection Widgets
  List<bool> _selection = [true, false, false];
  final List<String> _categories = [
    'Food',
    'Transport',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Health',
    'Savings',
  ];
  final Set<String> _selectedCategories = {'Food', 'Transport', 'Utilities'};

  bool _autoRepeat = false;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Budget',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Budget Name"),
            TextField(decoration: _inputDecoration("e.g., Monthly Essentials")),
            const SizedBox(height: 20),

            _buildLabel("Total Amount"),
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5568),
              ),
              decoration: _inputDecoration("").copyWith(
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: Colors.black87,
                  size: 28,
                ),
                hintText: "0.00",
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Period"),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ToggleButtons(
                isSelected: _selection,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selection.length; i++) {
                      _selection[i] = i == index;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.black87,
                fillColor: Colors.white,
                renderBorder: false,
                constraints: BoxConstraints(
                  minWidth: (MediaQuery.of(context).size.width - 45) / 3,
                  minHeight: 45,
                ),
                children: const [
                  Text("Monthly"),
                  Text("Weekly"),
                  Text("Custom"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Categories"),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: _categories
                  .map(
                    (cat) => FilterChip(
                      label: Text(cat),
                      selected: _selectedCategories.contains(cat),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(cat);
                          } else {
                            _selectedCategories.remove(cat);
                          }
                        });
                      },
                      backgroundColor: const Color(0xFFF1F4F8),
                      selectedColor: const Color(0xFFE0F7F3),
                      checkmarkColor: const Color(0xFF00C9A7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            _buildSwitchTile(
              "Auto-repeat Budget",
              _autoRepeat,
              (val) => setState(() => _autoRepeat = val),
            ),
            _buildSwitchTile(
              "Budget Exceed Notifications",
              _notifications,
              (val) => setState(() => _notifications = val),
            ),

            const SizedBox(height: 16),
            _buildInfoCard(
              Icons.psychology_outlined,
              "AI will suggest optimal budget allocations based on your spending history.",
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.sync,
              "Budgets are securely synced to your Firebase account across all devices.",
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF86E3D0,
                      ), // Soft teal from image
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Budget",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3748),
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00C9A7)),
    ),
  );

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00C9A7),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C9A7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
            ),
          ),
        ],
      ),
    );
  }
}
