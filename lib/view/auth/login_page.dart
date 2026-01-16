import 'package:expenxo/services/auth_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/auth/register_page.dart';
import 'package:expenxo/view/auth/responsive_auth_layout.dart';
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

      if (authService.currentUser != null && mounted) {
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
    return ResponsiveAuthLayout(
      title: "Welcome Back!",
      subtitle: "Enter your details to access your account.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          _buildLabel("Email Address"),
          TextField(
            controller: _emailController,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: _inputDecoration(
              context,
              "john@example.com",
              Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Password
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
                  "********",
                  Icons.lock_outline,
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
                style: TextStyle(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Sign In Button
          SizedBox(
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
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
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
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            ],
          ),
          const SizedBox(height: 30),

          // Google Login
          SizedBox(
            height: 55,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: Image.asset(
                'assets/icons/google.png',
                height: 24,
                width: 24,
                errorBuilder: (c, e, s) => Icon(Icons.g_mobiledata, size: 30),
              ),
              label: Text(
                "Continue with Google",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Create Account
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        size: 20,
      ),
      hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.mainColor),
      ),
    );
  }
}
