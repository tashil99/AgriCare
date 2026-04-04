import 'package:flutter/material.dart';
import '../../services/app_session.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/success_dialog.dart';
import '../home/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = authService;

  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (_username.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirm.text.isEmpty) {
      ErrorDialog.show(context, "Please fill all fields");
      return;
    }

    if (_password.text != _confirm.text) {
      ErrorDialog.show(context, "Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    final error = await _auth.register(
      username: _username.text,
      email: _email.text,
      password: _password.text,
      confirmPassword: _confirm.text,
    );

    setState(() => _loading = false);

    if (error != null) {
      ErrorDialog.show(context, error);
    } else {
      SuccessDialog.show(
        context,
        "Account created successfully",
        onContinue: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF4E1), Color(0xFFDFF2C8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [

                  /// LOGO (same as login)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo_1.png',
                      height: 70,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "AgriCare",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [

                        /// USERNAME
                        TextField(
                          controller: _username,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// EMAIL
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// PASSWORD
                        TextField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// CONFIRM PASSWORD
                        TextField(
                          controller: _confirm,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirm = !_obscureConfirm;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// REGISTER BUTTON WITH ICON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _register,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.person_add),
                            label: Text(
                              _loading ? "Creating..." : "Create Account",
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// LOGIN LINK WITH ICON
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.login),
                          label: const Text("Already have an account? Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}