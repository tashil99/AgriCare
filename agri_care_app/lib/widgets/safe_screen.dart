import 'package:flutter/material.dart';

class SafeScreen extends StatelessWidget {
  final Widget child;

  const SafeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}