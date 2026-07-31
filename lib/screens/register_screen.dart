import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = "tenant";
  bool _loading = false;
  bool _obscure = true;

  final List<Map<String, dynamic>> _roles = [
    {"id": "tenant", "label": "Tenant", "icon": Icons.person_rounded, "desc": "Report & track issues"},
    {"id": "landlord", "label": "Landlord", "icon": Icons.apartment_rounded, "desc": "Manage properties"},
    {"id": "technician", "label": "Technician", "icon": Icons.build_rounded, "desc": "Handle repairs"},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.trim().length >= 6;

  Future<void> _register() async {
    if (!_isValid) {
      _showError("Please fill all fields. Password must be 6+ characters.");
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final error = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    if (mounted) {
      setState(() => _loading = false);
      if (error != null) {
        _showError(error);
      }
      // On success, AuthWrapper automatically routes to the right dashboard.
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text("Create Account", style: AppTextStyles.h1),
              const SizedBox(height: 6),
              Text(
                "Join iRembo Maintenance",
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Role picker
              Text("I am a...", style: AppTextStyles.labelUppercase),
              const SizedBox(height: 10),
              Row(
                children: _roles.map((r) {
                  final isSelected = _selectedRole == r["id"];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = r["id"]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryLight : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              r["icon"],
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 26,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              r["label"],
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Text("Full Name", style: AppTextStyles.labelUppercase),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "e.g. Uwimana Diane",
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              Text("Email", style: AppTextStyles.labelUppercase),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "you@example.com",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              Text("Password", style: AppTextStyles.labelUppercase),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "At least 6 characters",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Create Account"),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: AppTextStyles.bodyMedium,
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
