import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'admin/admin_dashboard.dart';
import 'audience/audience_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_isSignUp) {
      // Registrations are strictly for audience / fan members
      success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: UserRole.audience,
      );
    } else {
      success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (success && mounted) {
      // Automatically route according to role:
      // - Admin (akash@gmail.com / admin role): opens Admin Dashboard with full scoring controls
      // - Audience: opens Audience Home with live scores and match updates
      if (authProvider.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AudienceHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo & Title
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_cricket,
                        color: AppColors.primary,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CRICPULSE LIVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSignUp
                        ? 'Create your Fan Account for Live Cricket Updates'
                        : 'Sign in to access Live Scores & Match Hub',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Error Banner
                  if (authProvider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.liveRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(fontSize: 12, color: AppColors.liveRed),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Name Field (only if registering)
                  if (_isSignUp) ...[
                    _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'e.g. Rahul Sharma',
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Email Field
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password Field
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 24),

                  // Single Unified Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: authProvider.isLoading ? null : _submit,
                    child: authProvider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text(
                            _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Switch between Login & Signup
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _emailController.clear();
                        _passwordController.clear();
                        _nameController.clear();
                        authProvider.clearError();
                      });
                    },
                    child: Text(
                      _isSignUp ? 'Already have an account? Sign In' : 'Need an account? Register as Fan',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
