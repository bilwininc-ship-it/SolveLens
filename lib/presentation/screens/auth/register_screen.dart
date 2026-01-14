// Premium Elite Register Screen - Ultra-Clean Design
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey, // Premium light grey #F8FAFC
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.primaryNavy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign up to get started with SolveLens',
                    style: TextStyle(
                      color: AppTheme.mediumGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
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
                  
                  // Register Form Card
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
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: AppTheme.primaryNavy,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: const TextStyle(
                                color: AppTheme.mediumGrey,
                                fontSize: 14,
                              ),
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(
                                color: AppTheme.mediumGrey.withOpacity(0.5),
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outlined,
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
                                return 'Please enter your name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
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
                          const SizedBox(height: 20),
                          
                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(
                              color: AppTheme.primaryNavy,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(
                                color: AppTheme.mediumGrey,
                                fontSize: 14,
                              ),
                              hintText: 'Confirm your password',
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
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.mediumGrey,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Terms and Conditions
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreedToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryNavy,
                                  checkColor: AppTheme.cleanWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'I agree to the Terms and Conditions',
                                  style: TextStyle(
                                    color: AppTheme.mediumGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Register Button - 50px height, 24px corners
                          SizedBox(
                            width: double.infinity,
                            height: 50, // Professional height
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading || !_agreedToTerms
                                  ? null
                                  : () => _handleRegister(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryNavy,
                                foregroundColor: AppTheme.cleanWhite,
                                disabledBackgroundColor: AppTheme.mediumGrey.withOpacity(0.3),
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
                                      'Create Account',
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
                  
                  // Google Sign In
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
                  
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.mediumGrey,
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.registerWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}
