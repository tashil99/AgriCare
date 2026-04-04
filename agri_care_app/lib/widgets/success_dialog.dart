import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SuccessDialog {
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onContinue,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {

        /// ⏱ AUTO CLOSE
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            if (onContinue != null) onContinue();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// ICON
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppTheme.primary,
                    size: 26,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Success",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}