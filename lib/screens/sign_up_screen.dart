import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../utils/toast_util.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();     // UI only
  final _mobileCtrl = TextEditingController();   // UI only
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _authService = AuthService();
  bool _loading = false;

  void _register() async {
    // ❗ Logic unchanged (as requested)
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ToastUtil.error("Please fill all fields");
      return;
    }

    setState(() => _loading = true);

    final success = await _authService.signUp(
      _emailCtrl.text,
      _passwordCtrl.text,
    );

    setState(() => _loading = false);

    if (success) {
      ToastUtil.success("Account created successfully");
      Navigator.pop(context); // ⬅ back to login
    } else {
      ToastUtil.error("User already exists");
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔙 Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                ),

                const SizedBox(height: 20),

                /// Logo
                const Center(child: AppLogo()),

                const SizedBox(height: 24),

                /// Title
                const Center(
                  child: Text(
                    "Sign Up Now",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    "Please fill the details to create account",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

                /// Name (UI only)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                /// Mobile (UI only)
                TextField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),

                const SizedBox(height: 16),

                /// Email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 16),

                /// Password
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),

                const SizedBox(height: 30),

                /// Register Button
                /// Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Create an Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// Small Helper Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account? ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Login or Sign Up
                      },
                      child: const Text(
                        "Log in here",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w600,
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
    );
  }
}
