import 'package:another_flushbar/flushbar.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  static void showToast(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    Flushbar(
      message: message,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        size: 28.0,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      leftBarIndicatorColor: isError ? AppColors.error : AppColors.success,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
      backgroundGradient: LinearGradient(
        colors: isError
            ? [Colors.red.shade800, Colors.red.shade400]
            : [AppColors.mainColor.withOpacity(0.9), AppColors.secondaryColor],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      ],
    ).show(context);
  }
}
