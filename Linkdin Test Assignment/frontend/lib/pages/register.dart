import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/top_popup.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String get baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://localhost:8000";
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      TopPopup.show(context, "Passwords do not match!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse("$baseUrl/api/users/register/");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'password2': confirmPasswordController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        TopPopup.show(
          context,
          'Registration Successful! Please login.',
          Colors.green,
        );

        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        TopPopup.show(
          context,
          'Registration failed: ${error['username'] ?? error['password'] ?? "Try again"}',
          Colors.red,
        );
      }
    } catch (e) {
      TopPopup.show(context, 'Error connecting to server.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          double cardWidth;
          if (width < 600) {
            cardWidth = width * 0.9; // Mobile
          } else if (width < 1024) {
            cardWidth = 500; // Tablet
          } else {
            cardWidth = 420; // Web/Desktop
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: cardWidth,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            size: 72,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'Register a new account',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// Username
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: "Username",
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter username'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          /// Email
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter email'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          /// Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter password'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          /// Confirm Password
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Confirm your password'
                                    : null,
                          ),
                          const SizedBox(height: 24),

                          _isLoading
                              ? const CircularProgressIndicator()
                              : Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: register,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Register",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginPage(),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Back to Login",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
