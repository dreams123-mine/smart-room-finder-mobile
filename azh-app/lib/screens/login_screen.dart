import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../models/roles.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  AzhlyRole? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

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

  String get _idLabel {
    return _selectedRole == AzhlyRole.teacher
        ? 'Employee ID'
        : 'Roll Number';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      final username = _usernameCtrl.text.trim();

      final response = await auth.mobileLogin(
        username: username,
        password: _passwordCtrl.text,
        role: _roleCode,
      );

      if (!mounted) return;

      final userData = <String, dynamic>{
        ...response,
        'username': username,
        'adminName': response['name'] ??
            response['fullName'] ??
            username,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Login successful!',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            role: _selectedRole!,
            userData: userData,
          ),
        ),
      );
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

Future<void> _goToRegister() async {
  final newId = await Navigator.of(context).push<String>(
    MaterialPageRoute(
      builder: (_) => const RegisterScreen(),
    ),
  );

  if (newId != null && mounted) {
    _usernameCtrl.text = newId;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Account created successfully! Please log in.",
        ),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/azhly_logo.png",
                          width: 90,
                          height: 90,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Smart Room Allocation System",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Login to your AZHly account",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 30),

                        DropdownButtonFormField<AzhlyRole>(
                          initialValue: _selectedRole,
                          dropdownColor: const Color(0xff15113A),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: "Select Your Role",
                            labelStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            prefixIcon: const Icon(
                              Icons.people_alt_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: .06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                              value == null ? "Please select your role" : null,
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _usernameCtrl,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: _idLabel,
                            labelStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: .06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? "Required"
                                  : null,
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: .06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Required"
                                  : null,
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("LOGIN"),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextButton(
                          onPressed: _isLoading ? null : _goToRegister,
                          child: const Text("Create New Account"),
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
