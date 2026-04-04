import 'package:flutter/material.dart';

class ErrorDialog {
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 26,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Error",
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

              const SizedBox(height: 20),

              Row(
                children: [

                  if (onRetry != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRetry();
                        },
                        child: const Text("Retry"),
                      ),
                    ),

                  if (onRetry != null)
                    const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}