import 'package:flutter/material.dart';
import '../widgets/gradient_border_textfield.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreedToPrivacyPolicy = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _agreedToPrivacyPolicy = false;
    });
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToPrivacyPolicy) {
        showCustomSnackBar(
          context,
          'Please agree to the privacy policy',
          type: SnackType.error,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final result = await ApiService.signup(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          // Signup successful
          showCustomSnackBar(
            context,
            result['message'] ?? 'Account created successfully',
            type: SnackType.success,
          );
          
          // Navigate back to login page
          _resetForm();
          Navigator.pop(context);
        } else {
          // Signup failed
          showCustomSnackBar(
            context,
            result['message'] ?? 'Signup failed',
            type: SnackType.error,
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        showCustomSnackBar(
          context,
          'An error occurred: ${e.toString()}',
          type: SnackType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      // Back arrow
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF6BD377),
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 30),
                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6BD377),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtitle
                      const Text(
                        'Sign up to continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Email field
                      GradientBorderTextField(
                        controller: _emailController,
                        hintText: 'Email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      GradientBorderTextField(
                        controller: _passwordController,
                        hintText: 'Create Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password field
                      GradientBorderTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Privacy policy checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreedToPrivacyPolicy,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToPrivacyPolicy = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF6BD377),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "I agree with JoseniCare's privacy policy.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Sign Up button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6BD377),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
                        // Login prompt at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF6BD377),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
