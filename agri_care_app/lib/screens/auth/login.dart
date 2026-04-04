import 'package:flutter/material.dart';
import '../../services/app_session.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/success_dialog.dart';
import '../home/home.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = authService;

  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      ErrorDialog.show(context, "Please fill all fields");
      return;
    }

    setState(() => _loading = true);

    final error = await _auth.login(
      username: _username.text,
      password: _password.text,
    );

    setState(() => _loading = false);

    if (error != null) {
      ErrorDialog.show(context, error);
    } else {
      SuccessDialog.show(
        context,
        "Login successful",
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

                  /// LOGO
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

                        /// PASSWORD
                        TextField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// LOGIN BUTTON WITH ICON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _login,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(_loading ? "Logging in..." : "Login"),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// CREATE ACCOUNT LINK WITH ICON
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            );
                          },
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text("Create account"),
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