import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/localization/app_localizations.dart';
import 'package:myecomerceapp/core/localization/locale_keys.dart';
import 'package:myecomerceapp/core/utils/app_responsive.dart';
import 'package:myecomerceapp/data/auth/models/user_creation_req.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';
import 'package:myecomerceapp/presentation/auth/page/signin.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _passwordController  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final firstName = _firstNameController.text.trim();
    final lastName  = _lastNameController.text.trim();
    final email     = _emailController.text.trim();
    final password  = _passwordController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack(context.tr(LK.fillAllFields));
      return;
    }
    if (password.length < 6) {
      _showSnack(context.tr(LK.passwordTooShort));
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await sl<AuthRepository>().signup(
        UserCreationReq(FirstName: firstName, LastName: lastName, Email: email, Password: password),
      );
      if (!mounted) return;
      result.fold(
        (l) => _showSnack(l?.toString() ?? context.tr(LK.error)),
        (_) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
        ),
      );
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    final c = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: c.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = R.hp(context);
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SigninPage()),
          ),
          icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary, size: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(LK.createAccount),
                style: GoogleFonts.oswald(
                  fontSize: R.sp(context, 30),
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(LK.createSubtitle),
                style: TextStyle(fontSize: R.sp(context, 14), color: c.textHint),
              ),
              const SizedBox(height: 32),
              R.isPhone(context)
                  ? Column(children: [
                      _field(c: c, controller: _firstNameController, label: context.tr(LK.firstName), icon: Icons.person_outline),
                      const SizedBox(height: 14),
                      _field(c: c, controller: _lastNameController, label: context.tr(LK.lastName), icon: Icons.person_outline),
                    ])
                  : Row(children: [
                      Expanded(child: _field(c: c, controller: _firstNameController, label: context.tr(LK.firstName), icon: Icons.person_outline)),
                      const SizedBox(width: 14),
                      Expanded(child: _field(c: c, controller: _lastNameController, label: context.tr(LK.lastName), icon: Icons.person_outline)),
                    ]),
              const SizedBox(height: 14),
              _field(c: c, controller: _emailController, label: context.tr(LK.email), icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field(
                c: c,
                controller: _passwordController,
                label: context.tr(LK.password),
                icon: Icons.lock_outline,
                obscureText: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: c.textHint, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: R.wp(context, 52),
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          context.tr(LK.createAccount),
                          style: TextStyle(color: c.textPrimary, fontSize: R.sp(context, 16), fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.tr(LK.alreadyHaveAccount), style: TextStyle(color: c.textSecondary, fontSize: R.sp(context, 14))),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SigninPage())),
                      child: Text(context.tr(LK.signIn), style: TextStyle(color: AppColors.accent, fontSize: R.sp(context, 14), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required AppColors c,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: c.textSecondary, fontSize: R.sp(context, 13), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: c.textPrimary, fontSize: R.sp(context, 15)),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.inputFill,
            prefixIcon: Icon(icon, color: c.textHint, size: 20),
            suffixIcon: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.divider)),
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: R.wp(context, 16)),
          ),
        ),
      ],
    );
  }
}
