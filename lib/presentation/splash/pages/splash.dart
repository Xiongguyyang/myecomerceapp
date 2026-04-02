import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myecomerceapp/presentation/auth/page/signin.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_cubit.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_state.dart';

class SplashPages extends StatefulWidget {
  const SplashPages({super.key});

  @override
  State<SplashPages> createState() => _SplashPagesState();
}

class _SplashPagesState extends State<SplashPages>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplasState>(
      listener: (context, state) {
        if (state is UnAuthentication) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, b) => SigninPage(),
              transitionsBuilder: (_, anim, b, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF002A36),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF001F2B),
                    Color(0xFF004054),
                    Color(0xFF006680),
                  ],
                ),
              ),
            ),
            // Decorative circle top-right
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Decorative circle bottom-left
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App icon with glow
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00AACC).withValues(alpha: 0.5),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/images/icon.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // App name
                        Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: Text(
                            'Flexy',
                            style: GoogleFonts.oswald(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: Text(
                            'Shop smarter. Live better.',
                            style: GoogleFonts.oswald(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.white54,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 64),
                        // Loading indicator
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
