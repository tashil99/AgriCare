import 'package:flutter/material.dart';
import '../../services/app_session.dart';
import '../../theme/app_theme.dart';
import '../auth/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text("Profile")),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 55,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      user?.username ?? "No user",
                      style: theme.textTheme.titleLarge,
                    ),

                    const SizedBox(height: 6),

                    /// EMAIL
                    Text(
                      user?.email ?? "No email",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// LOGOUT BUTTON
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    authService.logout();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}