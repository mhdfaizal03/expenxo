import 'package:expenxo/models/category_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/utils/ui/ui_helper.dart';
import 'package:expenxo/utils/toast_util.dart';
import 'package:expenxo/view/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  // State variables
  String categoryName = "";
  Color selectedColor = const Color(0xFF8E44AD);
  bool isExpense = true;
  IconData selectedIcon = Icons.category_rounded;

  bool _isLoading = false;

  final List<Color> availableColors = [
    const Color(0xFF00C9A7),
    const Color(0xFFFFC107),
    const Color(0xFFF25C54),
    const Color(0xFF8E44AD),
    const Color(0xFF3498DB),
    const Color(0xFF2ECC71),
    const Color(0xFFE67E22),
    const Color(0xFF95A5A6),
    const Color(0xFF34495E),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Category',
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
            _buildLabel("Category Name"),
            TextField(
              onChanged: (val) => setState(() => categoryName = val),
              decoration: _inputDecoration("e.g. Dining Out"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Select Icon"),
            GestureDetector(
              onTap: () => _showIconPicker(),
              child: _buildActionTile(selectedIcon, "Change Icon"),
            ),
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
                // _buildAddColorButton(), // Custom color picker can be next iteration
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel("Category Type"),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            _buildLabel("Preview"),
            _buildPreviewCard(),
            const SizedBox(height: 32),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  void _showIconPicker() {
    DialogUtils.showPremiumDialog(
      context: context,
      title: "Select Icon",
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 15, // Hardcoded length from original list
        itemBuilder: (context, index) {
          final icons = [
            Icons.restaurant,
            Icons.directions_car,
            Icons.shopping_bag,
            Icons.home,
            Icons.movie,
            Icons.medical_services,
            Icons.school,
            Icons.fitness_center,
            Icons.pets,
            Icons.work,
            Icons.flight,
            Icons.local_cafe,
            Icons.sports_esports,
            Icons.fastfood,
            Icons.local_grocery_store,
          ];
          final icon = icons[index];
          final isSelected = selectedIcon == icon;

          return InkWell(
            onTap: () {
              setState(() => selectedIcon = icon);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.mainColor.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.mainColor
                      : Colors.grey.shade200,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.mainColor : Colors.grey.shade700,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (categoryName.isEmpty) {
      ToastUtil.showToast(
        context,
        "Please enter a category name",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final category = CategoryModel(
        id: '',
        userId: '', // handled by service
        name: categoryName,
        iconCode: selectedIcon.codePoint,
        colorHex: selectedColor.value.toRadixString(16),
        type: isExpense ? 'Expense' : 'Income',
      );

      await Provider.of<FirestoreService>(
        context,
        listen: false,
      ).addCategory(category);

      if (mounted) {
        ToastUtil.showToast(context, "Category added successfully!");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ToastUtil.showToast(context, "Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI Components ---

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFF00C9A7)),
    ),
  );

  Widget _buildActionTile(IconData icon, String label) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color),
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

  // Widget _buildAddColorButton() => Container(
  //   width: 36,
  //   height: 36,
  //   decoration: BoxDecoration(
  //     shape: BoxShape.circle,
  //     border: Border.all(color: const Color(0xFFE2E8F0)),
  //   ),
  //   child: const Icon(Icons.add, color: Colors.grey, size: 20),
  // );

  Widget _buildTypeSelector() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
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
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(selectedIcon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              categoryName.isEmpty ? "Category Name" : categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
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
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFF25C54)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFFF25C54)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C9A7),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isLoading
                ? const ShimmerLoading.circular(width: 20, height: 20)
                : const Text(
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
