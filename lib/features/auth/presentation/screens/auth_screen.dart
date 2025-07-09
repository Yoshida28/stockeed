import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocked/core/theme/app_theme.dart';
import 'package:stocked/core/constants/app_constants.dart';
import 'package:stocked/features/auth/presentation/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _awaitingOtp = false;
  String _selectedRole = AppConstants.roleDistributor;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // App Logo/Title
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: AppTheme.glassmorphicDecoration,
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.cube_box_fill,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stocked',
                        style: AppTheme.heading1.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Business Management Made Simple',
                        style: AppTheme.body2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Auth Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glassmorphicDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        style: AppTheme.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      if (!_isLogin) ...[
                        _buildTextField(
                          controller: _nameController,
                          placeholder: 'Full Name',
                          icon: CupertinoIcons.person,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _phoneController,
                          placeholder: 'Phone Number',
                          icon: CupertinoIcons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _companyController,
                          placeholder: 'Company Name',
                          icon: CupertinoIcons.building_2_fill,
                        ),
                        const SizedBox(height: 16),
                        // Role selection removed
                      ],

                      _buildTextField(
                        controller: _emailController,
                        placeholder: 'Email Address',
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      if (_awaitingOtp)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CupertinoTextField(
                            controller: _otpController,
                            placeholder: 'Enter OTP',
                            keyboardType: TextInputType.number,
                            style: AppTheme.body1,
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Icon(CupertinoIcons.number,
                                  color: AppTheme.primaryColor, size: 20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: null,
                          ),
                        ),

                      _buildTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        icon: CupertinoIcons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),

                      if (_awaitingOtp)
                        CupertinoButton.filled(
                          onPressed: _isLoading ? null : _handleOtpSubmit,
                          child: _isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text('Verify OTP'),
                        ),
                      // Submit Button
                      CupertinoButton.filled(
                        onPressed: _isLoading ? null : _handleSubmit,
                        borderRadius: BorderRadius.circular(12),
                        child: _isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _isLogin ? 'Sign In' : 'Create Account',
                                style: AppTheme.body1,
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Login/Signup
                      CupertinoButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Sign Up'
                              : 'Already have an account? Sign In',
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        placeholderStyle: AppTheme.body2.copyWith(
          color: AppTheme.textSecondaryColor.withOpacity(0.6),
        ),
        style: AppTheme.body1,
        obscureText: isPassword,
        keyboardType: keyboardType,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: null,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = ref.read(authProviderNotifier.notifier);

      if (_isLogin) {
        await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          companyName: _companyController.text.trim(),
          role: 'distributor', // Always set to distributor
        );
        setState(() {
          _awaitingOtp = true;
        });
      }
    } catch (e, stack) {
      debugPrint('Auth error: $e');
      debugPrint('Stack: $stack');
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleOtpSubmit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = ref.read(authProviderNotifier.notifier);

      await authProvider.verifyOtp(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _companyController.text.trim(),
        role: 'distributor', // Always set to distributor
      );

      setState(() {
        _awaitingOtp = false;
      });
    } catch (e, stack) {
      debugPrint('OTP verification error: $e');
      debugPrint('Stack: $stack');
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
