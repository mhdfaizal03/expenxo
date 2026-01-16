import 'package:flutter/material.dart';
import 'package:expenxo/utils/constands/colors.dart';

class IconHelper {
  static final List<IconData> _supportedIcons = [
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
    // Add defaults just in case
    Icons.category,
    Icons.receipt_long,
  ];

  static IconData getIconFromCode(int codePoint) {
    try {
      return _supportedIcons.firstWhere(
        (icon) => icon.codePoint == codePoint,
        orElse: () => Icons.category, // Default fallback
      );
    } catch (e) {
      return Icons.category;
    }
  }
}

class DialogUtils {
  /// Shows a generic premium dialog with scale/fade animation
  static Future<T?> showPremiumDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: title,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: content,
                    ),
                  ),

                  // Actions
                  if (actions != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions
                            .map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: a,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (actions == null) const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  /// Shows a styled confirmation dialog (e.g. for delete)
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = "Confirm",
    String cancelLabel = "Cancel",
    Color? confirmColor,
    IconData? icon,
    bool isDestructive = false,
  }) {
    final color =
        confirmColor ??
        (isDestructive ? Colors.redAccent : AppColors.mainColor);
    final iconData =
        icon ??
        (isDestructive
            ? Icons.warning_amber_rounded
            : Icons.info_outline_rounded);

    return showPremiumDialog<bool>(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class PremiumDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hint;
  final IconData? icon;

  const PremiumDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = "Select",
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color:
                  Theme.of(context).iconTheme.color?.withOpacity(0.7) ??
                  Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color:
                      Theme.of(context).iconTheme.color?.withOpacity(0.5) ??
                      Colors.grey.shade600,
                ),
                isExpanded: true,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                borderRadius: BorderRadius.circular(16),
                dropdownColor: Theme.of(context).cardColor,
                elevation: 4,
                onChanged: onChanged,
                items: items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
