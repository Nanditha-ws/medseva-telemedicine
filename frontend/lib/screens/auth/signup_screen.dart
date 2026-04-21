/// Signup Screen
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Doctor fields
  final _specializationController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _regNumberController = TextEditingController();

  String _selectedRole = 'patient';
  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is String) {
      _selectedRole = extra;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _regNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _selectedRole,
    };

    if (_selectedRole == 'doctor') {
      data['specialization'] = _specializationController.text.trim();
      data['qualification'] = _qualificationController.text.trim();
      data['registration_number'] = _regNumberController.text.trim();
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(data);

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: AppTheme.accentRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Registering as ${_selectedRole[0].toUpperCase()}${_selectedRole.substring(1)}',
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController, label: 'First Name',
                      prefixIcon: Icons.person_outlined,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController, label: 'Last Name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController, label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController, label: 'Phone Number',
                prefixIcon: Icons.phone_outlined, hint: '+91-XXXXXXXXXX',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Doctor-specific fields
              if (_selectedRole == 'doctor') ...[
                CustomTextField(
                  controller: _specializationController, label: 'Specialization',
                  prefixIcon: Icons.medical_services_outlined,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _qualificationController, label: 'Qualification',
                  prefixIcon: Icons.school_outlined, hint: 'e.g., MBBS, MD',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _regNumberController, label: 'Registration Number',
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
              ],

              CustomTextField(
                controller: _passwordController, label: 'Password',
                prefixIcon: Icons.lock_outlined, obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController, label: 'Confirm Password',
                prefixIcon: Icons.lock_outlined, obscureText: true,
                validator: (v) {
                  if (v != _passwordController.text) return 'Passwords don\'t match';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return CustomButton(
                    text: 'Create Account',
                    isLoading: auth.isLoading,
                    onPressed: _handleSignup,
                    isFullWidth: true,
                  );
                },
              ),
              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Sign In', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
