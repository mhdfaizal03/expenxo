import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/ui/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:expenxo/utils/constands/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionItemWidget extends StatefulWidget {
  final TransactionModel transaction;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final IconData icon;

  const TransactionItemWidget({
    super.key,
    required this.transaction,
    required this.currencyFormat,
    required this.dateFormat,
    required this.icon,
  });

  @override
  State<TransactionItemWidget> createState() => _TransactionItemWidgetState();
}

class _TransactionItemWidgetState extends State<TransactionItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == 'Income';
    final amountColor = isIncome
        ? const Color(0xFF00C9A7)
        : const Color(0xFFFF5252);
    final prefix = isIncome ? "+" : "-";

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.glassBgDark
                    : AppColors.glassBgLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  width: 1,
                ),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withAlpha((0.05 * 255).toInt())
                                  : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.blueGrey.shade300,
                              size: 24,
                            ),
                          )
                          .animate(target: _isExpanded ? 1 : 0)
                          .rotate(begin: 0, end: 0.1),
                      const SizedBox(width: 18),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.transaction.title.isNotEmpty
                                  ? widget.transaction.title
                                  : widget.transaction.category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.dateFormat.format(widget.transaction.date),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$prefix${widget.currencyFormat.format(widget.transaction.amount)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: amountColor,
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isExpanded)
                    Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                thickness: 0.5,
                                height: 2,
                                color: Colors.grey[600]!,
                              ),
                            ),
                            _buildDetailRow(
                              "Category",
                              widget.transaction.category,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              "Type",
                              widget.transaction.type,
                              valueColor: amountColor,
                            ),
                            if (widget.transaction.description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                "Description",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.transaction.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    bool? confirm =
                                        await DialogUtils.showConfirmDialog(
                                          context: context,
                                          title: "Delete Transaction?",
                                          message:
                                              "This action cannot be undone.",
                                          isDestructive: true,
                                          confirmLabel: "Delete",
                                        );

                                    if (confirm == true) {
                                      if (context.mounted) {
                                        await Provider.of<FirestoreService>(
                                          context,
                                          listen: false,
                                        ).deleteTransaction(
                                          widget.transaction.id,
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                  ),
                                  label: const Text("Delete"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: -0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
