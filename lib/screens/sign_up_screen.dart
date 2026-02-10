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
  // Controllers for input fields
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _authService = AuthService();
  bool _loading = false;

  /// Helper to validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Registration Logic
  void _register() async {
    final name = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // 1. Validation Checks
    if (name.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
      ToastUtil.error("Please fill in all fields");
      return;
    }

    if (!_isValidEmail(email)) {
      ToastUtil.error("Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      ToastUtil.error("Password must be at least 6 characters");
      return;
    }

    setState(() => _loading = true);

    // 2. Call the API via AuthService
    // Note: We send name and mobile as well if your backend supports them
    final success = await _authService.signUp(email, password);

    setState(() => _loading = false);

    // 3. Handle the response
    if (success) {
      ToastUtil.success("Account created successfully!");
      if (!mounted) return;
      // Navigate back to LoginScreen
      Navigator.pop(context);
    } else {
      ToastUtil.error("Registration failed. Email might already be in use.");
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
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Back Button to return to Login
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                ),

                const SizedBox(height: 10),
                const Center(child: AppLogo()),
                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Join our community and start detecting",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 32),

                /// Name Field
                _buildTextField(
                  controller: _nameCtrl,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                /// Mobile Field
                _buildTextField(
                  controller: _mobileCtrl,
                  label: "Mobile Number",
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                /// Email Field
                _buildTextField(
                  controller: _emailCtrl,
                  label: "Email Address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                /// Password Field
                _buildTextField(
                  controller: _passwordCtrl,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 32),

                /// Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Footer: Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Log in here",
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
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

  /// Custom text field builder for consistency
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
        ),
      ),
    );
  }
}