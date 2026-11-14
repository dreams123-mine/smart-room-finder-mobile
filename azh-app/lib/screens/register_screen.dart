import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../models/roles.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _universityIdCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _claimCodeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  AzhlyRole? _selectedRole;
  bool _isLoading = false;

  String get _roleCode {
    switch (_selectedRole!) {
      case AzhlyRole.teacher:
        return 'TEACHER';
      case AzhlyRole.crGr:
        return 'CR_GR';
      case AzhlyRole.student:
        return 'STUDENT';
    }
  }

  @override
  void dispose() {
    _universityIdCtrl.dispose();
    _emailCtrl.dispose();
    _claimCodeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final universityId = _universityIdCtrl.text.trim();

      final response = await auth.mobileRegister(
        universityId: universityId,
        email: _emailCtrl.text.trim(),
        role: _roleCode,
        claimCode: _claimCodeCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Registration successful!',
          ),
        ),
      );

      Navigator.of(context).pop(universityId);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff071224),
              Color(0xff15113A),
              Color(0xff0F1D35),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ),
                child: Container(
                  width: 370,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/azhly_logo.png',
                          width: 90,
                          height: 90,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Smart Room Allocation System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Verify your university details to join AZHly',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 30),

                        DropdownButtonFormField<AzhlyRole>(
                          initialValue: _selectedRole,
                          dropdownColor: const Color(0xff15113A),
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            label: 'Select Your Role',
                            icon: Icons.people_alt_outlined,
                          ),
                          items: AzhlyRole.values.map((role) {
                            return DropdownMenuItem<AzhlyRole>(
                              value: role,
                              child: Text(role.label),
                            );
                          }).toList(),
                          onChanged: _isLoading
                              ? null
                              : (role) {
                                  setState(() {
                                    _selectedRole = role;
                                  });
                                },
                          validator: (value) =>
                              value == null ? 'Please select your role' : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _universityIdCtrl,
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.characters,
                          decoration: _fieldDecoration(
                            label: 'University ID',
                            icon: Icons.badge_outlined,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'University ID is required'
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            label: 'University Email',
                            icon: Icons.email_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.trim().contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _claimCodeCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            label: 'Claim Code',
                            icon: Icons.key_outlined,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Claim code is required'
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            label: 'Create Password',
                            icon: Icons.lock_outline,
                          ),
                          validator: (value) =>
                              value == null || value.length < 4
                                  ? 'Minimum 4 characters'
                                  : null,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            label: 'Confirm Password',
                            icon: Icons.lock_reset_outlined,
                          ),
                          validator: (value) =>
                              value != _passwordCtrl.text
                                  ? 'Passwords do not match'
                                  : null,
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('REGISTER'),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Already have an account? Login',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
