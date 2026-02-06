import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/services/auth_service.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/utils/ui/ui_helper.dart';
import 'package:expenxo/view/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/utils/toast_util.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  // State variables for form fields
  String selectedSource = 'Salary';
  DateTime selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveIncome() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      ToastUtil.showToast(context, 'Please enter an amount', isError: true);
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null) {
      ToastUtil.showToast(
        context,
        'Please enter a valid amount',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) throw Exception("User not logged in");

      final transaction = TransactionModel(
        id: '',
        userId: user.uid,
        title: selectedSource,
        amount: amount,
        type: 'Income',
        category: selectedSource,
        date: selectedDate,
        description: _noteController.text,
      );

      await Provider.of<FirestoreService>(
        context,
        listen: false,
      ).addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(context, 'Error saving income: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Income',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall?.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 16),
              decoration: _inputDecoration("").copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    Provider.of<PreferencesProvider>(context).currencySymbol,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
                hintText: "0.00",
              ),
            ),
            const SizedBox(height: 20),

            // Source Selection
            _buildLabel("Source"),
            PremiumDropdown<String>(
              value: selectedSource,
              icon: Icons.account_balance_wallet_outlined,
              items: ['Salary', 'Freelance', 'Investment', 'Other'].map((
                String item,
              ) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: (val) => setState(() => selectedSource = val!),
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
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes Field
            _buildLabel("Notes"),
            TextField(
              controller: _noteController,
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
                onPressed: _isLoading ? null : _saveIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const ShimmerLoading.circular(width: 20, height: 20)
                    : const Text(
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
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
      ),
    );
  }

  // UI Helper: Standard Label
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  // UI Helper: Common Container Decoration
  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).dividerColor),
    );
  }

  // UI Helper: TextField Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.mainColor),
      ),
    );
  }
}
