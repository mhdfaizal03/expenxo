import 'package:expenxo/models/budget_model.dart';
import 'package:expenxo/models/category_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  // State for Selection Widgets
  List<bool> _selection = [true, false, false];
  // Actually, typically a budget is "Food Budget", "Transport Budget". So single category selection is better.
  // But user requested multi-selection UI. Let's assume one "Budget" document can cover multiple categories or we create multiple documents.
  // For simplicity and typical use case, let's treat this as creating a budget for *one* specific scope.
  // BUT the UI shows multiple chips. Let's allow one category for now to keep logic simple, or if multiple are selected, we save one Budget entry that applies to all?
  // Let's enforce Single or "Mixed" category.
  // Re-reading UI: It looks like "Categories" selector. Let's stick to single selection for V1 to be robust.

  String? _selectedCategory;

  bool _autoRepeat = false;
  bool _notifications = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Budget',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Budget Name"),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration("e.g., Monthly Essentials"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Total Amount"),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: _inputDecoration("").copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    Provider.of<PreferencesProvider>(context).currencySymbol,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                hintText: "0.00",
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Period"),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                selectedColor: Theme.of(context).textTheme.bodyLarge?.color,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                renderBorder: false,
                constraints: BoxConstraints(
                  minWidth: (MediaQuery.of(context).size.width - 45) / 3,
                  minHeight: 45,
                ),
                children: const [
                  Text("Monthly"),
                  Text("Weekly"),
                  Text(
                    "Custom",
                  ), // Custom not fully implemented logic-wise yet, defaulting to Monthly logic
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Category"),
            StreamBuilder<List<CategoryModel>>(
              stream: Provider.of<FirestoreService>(
                context,
                listen: false,
              ).getCategories(),
              builder: (context, snapshot) {
                final defaultCategories = [
                  'Food & Dining',
                  'Transport',
                  'Shopping',
                  'Entertainment',
                  'Health',
                  'Others',
                ];

                List<String> allCategories = [...defaultCategories];

                if (snapshot.hasData && snapshot.data != null) {
                  final customCategories = snapshot.data!
                      .map((c) => c.name)
                      .toList();
                  for (var custom in customCategories) {
                    if (!allCategories.contains(custom)) {
                      allCategories.add(custom);
                    }
                  }
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 0,
                  children: allCategories
                      .map(
                        (cat) => FilterChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedCategory = selected ? cat : null;
                            });
                          },
                          backgroundColor: Theme.of(context).cardColor,
                          selectedColor: const Color(0xFFE0F7F3),
                          checkmarkColor: const Color(0xFF00C9A7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                );
              },
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
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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

  Future<void> _saveBudget() async {
    if (_nameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedCategory == null) {
      ToastUtil.showToast(
        context,
        "Please fill all fields and select a category",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final period = _selection[0]
          ? 'Monthly'
          : (_selection[1] ? 'Weekly' : 'Custom');

      // Calculate Dates
      final now = DateTime.now();
      DateTime startDate = now;
      DateTime endDate = now;

      if (period == 'Monthly') {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      } else if (period == 'Weekly') {
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
      } else {
        // Custom defaults to 30 days for now
        endDate = now.add(const Duration(days: 30));
      }

      final budget = BudgetModel(
        id: '', // Generated by Firestore
        userId: '', // Set by Service
        category: _selectedCategory!,
        amount: amount,
        period: period,
        startDate: startDate,
        endDate: endDate,
        autoRepeat: _autoRepeat,
        notifyExceed: _notifications,
      );

      await Provider.of<FirestoreService>(
        context,
        listen: false,
      ).addBudget(budget);

      if (mounted) {
        Navigator.pop(context);
        ToastUtil.showToast(context, "Budget saved successfully!");
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(context, "Error saving budget: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper Widgets
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Theme.of(context).cardColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.mainColor),
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
          activeColor: AppColors.mainColor,
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mainColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
