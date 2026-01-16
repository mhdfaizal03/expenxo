import 'package:expenxo/services/auth_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/auth/register_page.dart';
import 'package:expenxo/view/nav_bar.dart';
import 'package:expenxo/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenxo/providers/preferences_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastUtil.showToast(context, 'Please fill in all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (authService.currentUser != null) {
        if (mounted) {
          // Sync preferences
          await Provider.of<PreferencesProvider>(
            context,
            listen: false,
          ).syncFromFirestore();

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => NavBar()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(
          context,
          'Login failed: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle();
      if (user != null && mounted) {
        // Sync preferences
        await Provider.of<PreferencesProvider>(
          context,
          listen: false,
        ).syncFromFirestore();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavBar()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(
          context,
          "Google Sign-In failed: ${e.toString()}",

          isError: true,
        );
      }
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController resetEmailController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (resetEmailController.text.isNotEmpty) {
                  try {
                    await Provider.of<AuthService>(
                      context,
                      listen: false,
                    ).sendPasswordResetEmail(resetEmailController.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      ToastUtil.showToast(
                        context,
                        'Password reset email sent!',
                        isError: false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtil.showToast(
                        context,
                        'Error: ${e.toString()}',
                        isError: true,
                      );
                    }
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo/Brand Name
                    SizedBox(
                      height: 180,
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? 'assets/logo3.png'
                            : 'assets/logo2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Header
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email/Phone Input
                    _buildLabel("Email"),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: _inputDecoration(context, "Enter your email"),
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    _buildLabel("Password"),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration:
                          _inputDecoration(
                            context,
                            "Enter your password",
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                          ),
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppColors.mainColor),
                        ),
                      ),
                    ),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Theme.of(context).dividerColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Theme.of(context).dividerColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Social Logins
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                            context,
                            "Continue with Google",
                            Icons.api,
                            onPressed: _signInWithGoogle,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Create Account Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  // Helper: Label Style
  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  // Helper: Common Input Decoration
  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.mainColor),
      ),
    );
  }

  // Helper: Social Buttons
  Widget _socialButton(
    BuildContext context,
    String text,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, color: Theme.of(context).iconTheme.color, size: 24),
        label: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).cardColor,
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
