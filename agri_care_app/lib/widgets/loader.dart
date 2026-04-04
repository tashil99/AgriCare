import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumLoader extends StatefulWidget {
  const PremiumLoader({super.key});

  @override
  State<PremiumLoader> createState() => _PremiumLoaderState();
}

class _PremiumLoaderState extends State<PremiumLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = (_controller.value - delay).clamp(0.0, 1.0);
        final scale = 0.5 + (value * 0.5);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),

          /// Animated dots loader
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(0.0),
              _dot(0.2),
              _dot(0.4),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            "Loading...",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}