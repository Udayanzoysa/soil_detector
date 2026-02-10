import 'package:flutter/material.dart';
import 'package:soil_detector/screens/sign_up_screen.dart';
import '../navigation/main_navigation.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../utils/toast_util.dart';
import 'loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ToastUtil.error("Please fill in all fields");
      return;
    }

    if (!_isValidEmail(email)) {
      ToastUtil.error("Please enter a valid email address");
      return;
    }

    setState(() => _loading = true);
    final isSuccess = await _authService.login(email, password);
    setState(() => _loading = false);

    if (isSuccess) {
      ToastUtil.success("Login successful");
      if (!mounted) return;
      // ✅ FIX: Navigate to MainNavigation, NOT DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      ToastUtil.error("Invalid email/password or server unreachable");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AppLogo(),
                  const SizedBox(height: 24),
                  const Text("Log In Now", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text("Log In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: () {
                          // NAVIGATE TO SIGN UP
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                        },
                        child: Text("Sign Up", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
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