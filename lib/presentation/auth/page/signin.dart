import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/utils/app_responsive.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';
import 'package:myecomerceapp/presentation/auth/page/signup.dart';
import 'package:myecomerceapp/presentation/home/pages/home_page.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please enter email and password');
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await sl<AuthRepository>().signin(email, password);
      if (!mounted) return;
      result.fold(
        (l) => _showSnack(l?.toString() ?? 'Sign in failed'),
        (_) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        ),
      );
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = R.hp(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Logo / icon
                  Center(
                    child: Container(
                      width: R.wp(context, 80),
                      height: R.wp(context, 80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Welcome back',
                    style: GoogleFonts.oswald(
                      fontSize: R.sp(context, 30),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue to Flexy',
                    style: TextStyle(
                      fontSize: R.sp(context, 14),
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email
                  _label('Email'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _emailController,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _label('Password'),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: _passwordController,
                    hint: '••••••••',
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: R.wp(context, 52),
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.accent),
                          )
                        : ElevatedButton(
                            onPressed: _signin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: R.sp(context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 24),

                  // Create account
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: R.sp(context, 14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: R.sp(context, 14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: R.sp(context, 13),
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: AppColors.textPrimary, fontSize: R.sp(context, 15)),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: R.sp(context, 14)),
        filled: true,
        fillColor: AppColors.inputFill,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textHint, size: 20)
            : null,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: R.wp(context, 16),
        ),
      ),
    );
  }
}
