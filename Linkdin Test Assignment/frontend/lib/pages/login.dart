import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // kIsWeb

import '../helpers/top_popup.dart';
import '../dashboards/admin_dashboard.dart';
import '../dashboards/user_dashboard.dart' as user_dash;
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String get baseUrl {
    return "https://ahsanrazatalpur.pythonanywhere.com";
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse("$baseUrl/api/users/login/");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ---------------- RELIABLE DATA EXTRACTION ----------------
        final token = data['access']?.toString() ?? '';
        final username = data['username']?.toString() ?? '';
        final email = data['email']?.toString() ?? '';
        final userId = data['id'] is int ? data['id'] : int.tryParse('${data['id']}') ?? 0;

        // Use role from backend directly
        final roleFromBackend = data['role']?.toString().toLowerCase() ?? 'user';
        final isAdmin = roleFromBackend == 'admin';
        final role = isAdmin ? 'admin' : 'user';
        // ----------------------------------------------------------

        if (token.isEmpty) {
          TopPopup.show(context, 'Login failed. Invalid credentials.', Colors.red);
          setState(() => _isLoading = false);
          return;
        }

        // Save session info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('username', username);
        await prefs.setString('email', email);
        await prefs.setInt('user_id', userId);
        await prefs.setString('role', role);
        await prefs.setBool('is_admin', isAdmin);

        TopPopup.show(context, 'Login Successful!', Colors.green);

        usernameController.clear();
        passwordController.clear();

        // ---------------- NAVIGATE TO DASHBOARD ----------------
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isAdmin
                ? AdminDashboardPage(
                    token: token,
                    username: username,
                    userId: userId,
                  )
                : user_dash.UserDashboard(
                    token: token,
                    username: username,
                  ),
          ),
        );
      } 
      // ✅ FIX: Handle 403 (blocked user) separately
      else if (response.statusCode == 403) {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error'] ?? 'Your account has been blocked by admin.';
        
        // Show blocked user dialog
        if (!mounted) return;
        _showBlockedUserDialog(errorMsg);
      } 
      // ✅ FIX: Handle 401 (invalid credentials)
      else if (response.statusCode == 401) {
        TopPopup.show(context, 'Invalid username or password', Colors.red);
      } 
      else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final errorMsg = errorData['error'] ??
            errorData['detail'] ??
            errorData['non_field_errors']?.join(', ') ??
            'Login failed. Please try again.';
        TopPopup.show(context, errorMsg, Colors.red);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      TopPopup.show(context, 'Error connecting to server.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ NEW: Show blocked user dialog
  void _showBlockedUserDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade300, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.red.shade700, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Account Blocked',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please contact the administrator for assistance.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final double cardWidth = isMobile ? double.infinity : 420;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_cart,
                              size: 72, color: Colors.indigo),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Login to your account',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          // Username
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: "Username",
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter username'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter password'
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
                                        onPressed: login,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                        child: const Text(
                                          "Login",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterPage(),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                        child: const Text(
                                          "Register New User",
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