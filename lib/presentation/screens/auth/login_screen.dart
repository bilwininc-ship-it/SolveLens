// Premium Elite Login Screen - Ultra-Clean Design
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey, // Premium light grey #F8FAFC
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Premium Logo Section
                  _buildPremiumLogo(),
                  const SizedBox(height: 48),

                  // Welcome Text
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign in to continue your learning journey',
                    style: TextStyle(
                      color: AppTheme.mediumGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Error Message
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.cleanWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.errorRed.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.errorRed,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.errorRed,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.cleanWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          blurRadius: 15,
                          color: const Color(0x0D000000),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: AppTheme.primaryNavy,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                color: AppTheme.mediumGrey,
                                fontSize: 14,
                              ),
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                color: AppTheme.mediumGrey.withOpacity(0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppTheme.primaryNavy,
                                size: 22,
                              ),
                              filled: true,
                              fillColor: AppTheme.lightGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.mediumGrey.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryNavy,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
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
                          const SizedBox(height: 20),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: AppTheme.primaryNavy,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(
                                color: AppTheme.mediumGrey,
                                fontSize: 14,
                              ),
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                color: AppTheme.mediumGrey.withOpacity(0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outlined,
                                color: AppTheme.primaryNavy,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.mediumGrey,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: AppTheme.lightGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.mediumGrey.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryNavy,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
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
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog(context, authProvider);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryNavy,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Login Button - 50px height, 24px corners
                          SizedBox(
                            width: double.infinity,
                            height: 50, // Professional height
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => _handleLogin(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: AppTheme.cleanWhite,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24), // 24px corners
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.cleanWhite,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Divider with OR
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppTheme.mediumGrey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppTheme.mediumGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppTheme.mediumGrey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Google Sign In - Premium outline button
                  SizedBox(
                    width: double.infinity,
                    height: 50, // Professional height
                    child: OutlinedButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleGoogleSignIn(authProvider),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppTheme.cleanWhite,
                        foregroundColor: AppTheme.primaryNavy,
                        side: BorderSide(
                          color: AppTheme.mediumGrey.withOpacity(0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24), // 24px corners
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.g_mobiledata_rounded,
                            color: AppTheme.primaryNavy,
                            size: 28,
                          );
                        },
                      ),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppTheme.mediumGrey,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.school_rounded,
          size: 48,
          color: AppTheme.primaryNavy,
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      await authProvider.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    await authProvider.signInWithGoogle();
  }

  void _showForgotPasswordDialog(
      BuildContext context, AuthProvider authProvider) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cleanWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(
                  color: AppTheme.mediumGrey,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppTheme.primaryNavy,
                ),
                filled: true,
                fillColor: AppTheme.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryNavy,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mediumGrey,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final success = await authProvider
                    .sendPasswordResetEmail(emailController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password reset email sent!'
                            : 'Failed to send reset email',
                      ),
                      backgroundColor:
                          success ? AppTheme.successGreen : AppTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: AppTheme.cleanWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Send',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
