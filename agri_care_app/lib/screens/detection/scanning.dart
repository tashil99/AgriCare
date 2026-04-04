import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_theme.dart';

class ScanningScreen extends StatelessWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🌱 Animation
                Lottie.asset(
                  "assets/animations/plant_scan.json",
                  width: 220,
                ),

                const SizedBox(height: 24),

                /// Title
                Text(
                  "Scanning your crop...",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                /// Subtitle
                Text(
                  "AI is analysing the leaf",
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 30),

                /// Loader (adds feedback)
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}