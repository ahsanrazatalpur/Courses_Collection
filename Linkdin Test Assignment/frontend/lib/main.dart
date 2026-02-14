import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login.dart';
import 'dashboards/admin_dashboard.dart';
import 'dashboards/user_dashboard.dart' as user_dash;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final username = prefs.getString('username') ?? '';
    final userId = prefs.getInt('user_id') ?? 0;

    // ------------------ FIXED ROLE CHECK ------------------
    String? role = prefs.getString('role'); // Try to get role
    bool isAdmin = prefs.getBool('is_admin') ?? false; // ✅ NON-NULLABLE

    if (role != null) {
      isAdmin = role.toLowerCase() == 'admin';
    } else {
      role = isAdmin ? 'admin' : 'user';
    }
    // -------------------------------------------------------

    // Optional splash delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (token.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      ),
    );
  }
}
