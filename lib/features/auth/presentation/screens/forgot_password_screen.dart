import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/email_launcher.dart';
import '../../logic/providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(_emailController.text);

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
      _showSnackBar('Password reset email sent. Check your inbox.', isError: false);
    } else {
      _showSnackBar(
        authProvider.errorMessage ?? 'Failed to send reset email',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _launchSupportEmail() async {
    final authProvider = context.read<AuthProvider>();
    final userUid = authProvider.currentUser?.uid ?? 'anonymous';
    
    try {
      await EmailLauncher.launchSupport(userUid: userUid);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not open email client. Please email us at bilwininc@gmail.com', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppColors.navyDark,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: AppColors.cyanNeon,
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.ivory,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      _emailSent
                          ? 'If an account exists with this email, you will receive a password reset link shortly.'
                          : 'Enter your email address and we\'ll send you a link to reset your password.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    if (!_emailSent) ...[
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 24),

                      // Reset Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.navy,
                                    ),
                                  )
                                : const Text('Send Reset Link'),
                          );
                        },
                      ),
                    ] else ...[
                      // Success message with back button
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Back to Login'),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Back to Login
                    if (!_emailSent)
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Login'),
                      ),
                    
                    const SizedBox(height: 16),

                    // Support Button
                    OutlinedButton.icon(
                      onPressed: _launchSupportEmail,
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('Need Help? Contact Support'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.greyDark, width: 1),
                        foregroundColor: AppColors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}